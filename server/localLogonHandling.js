const uuid = require('uuid');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');

module.exports = function initialize(params) {
  const { knex, util, emails } = params;

  // function login(req, res, next) {
  function login(req, res) {
    const sessionId = uuid.v4();
    let user = null;
    const email = req.body.email;
    const password = req.body.password;

    return knex('users').whereRaw('settings->>\'email_address\' = ?', [email]).first()
      .then(item => {
        if (item) {
          user = item;
          return knex('remote_user_register').where({ remote_id: user.remote_id }).first();
        }
        throw new Error('Invalid email address');
      })
      .then(remote_user => {
        // Allow login only if user found also in remote register
        if (remote_user) {
          return bcrypt.compare(password, user.pw_hash);
        }
        throw new Error('User not in remote register');
      })
      .then(isValid => {
        if (isValid) {
          return Promise.all([
            knex('sessions').insert({
              id: sessionId,
              user_id: user.id,
            }),
            knex('events').insert({
              type: 'login_success',
              data: { user_id: user.id, session_id: sessionId },
            }),
          ]).then(() => {
            req.session.id = sessionId;
            return res.json({ status: 'Ok' });
          });
        }
        throw new Error('Invalid password');
      })
      .catch(err => knex('events').insert({ type: 'login_failure', data: { error: err.message, email } })
        .then(() => res.status(401).json({ status: 'Failure', message: 'Login failed' }))
      );
  }

  function logout(req, res, next) {
    let sessionId;
    if (req.session.id) {
      return util.userForSession(req)
        .then(user => {
          sessionId = req.session.id;
          req.session = null;
          return knex('events').insert({ type: 'logout_success', data: { session_id: sessionId, user_id: user.id } });
        }).then(() => knex('sessions').where({ id: sessionId }).del()
        ).then(() => res.redirect('/')
        )
        .catch(next);
    }
    return knex('events').insert({ type: 'logout_failure', data: { message: 'no_session_id' } })
      .then(() => res.redirect('/'));
  }

  function changePassword(req, res, next) {
    const oldPassword = req.body.oldPassword;
    const newPassword = req.body.newPassword;
    const newPassword2 = req.body.newPassword2;
    let user;

    if (req.session.id) {
      return util.userForSession(req)
        .then(item => {
          user = item;
          const pw_hash = item.pw_hash;
          return bcrypt.compare(oldPassword, pw_hash);
        })
        .then(isValid => {
          if (!isValid) {
            return knex('events').insert({ type: 'change_password_failure', data: { message: 'Wrong old password', user_id: user.id } })
              .then(() => res.status(403).json({ status: 'Wrong old password' }));
          }
          if (newPassword !== newPassword2) {
            return knex('events').insert({ type: 'change_password_failure', data: { message: 'Passwords don\'t match', user_id: user.id } })
              .then(() => res.status(500).json({ status: 'Passwords don\'t match' }));
          }
          // Change password here
          const newHash = bcrypt.hashSync(newPassword);
          return knex('users').where({ id: user.id }).update({ pw_hash: newHash })
            .then(() => knex('events').insert({ type: 'change_password_success', data: { user_id: user.id } }))
            .then(() => res.status(200).json({ status: 'Ok' }));
        })
        .catch(next);
    }

    // No session id
    return knex('events').insert({ type: 'logout_failure', data: { message: 'no_session_id' } })
      .then(() => res.redirect('/'));
  }

  // Allow registration if the user is in users and pw_hash == null
  function register(req, res) {
    const email = req.body.email;
    let user = null;
    knex('users').whereRaw('settings->>\'email_address\' = ?', [email]).first()
      .then(item => {
        user = item;
        if (!user) {
          throw new Error('No such email address');
        }
        if (user.pw_hash != null) {
          throw new Error('User already registered');
        }
        return knex('reset_password_request').where({ user_id: user.id }).whereRaw('created_at > NOW() - INTERVAL \'1 day\'').first();
      })
      .then(reg_item => {
        if (reg_item == null) {
          const uniqueToken = crypto.randomBytes(48).toString('hex');
          emails.sendRegistrationEmail(email, uniqueToken);
          return knex('reset_password_request').insert({ user_id: user.id, url_token: uniqueToken });
        }
        throw new Error('Already pending');
      })
      .then(() => knex('events').insert({ type: 'register', data: { email: email } }))
      .then(() => res.json({ status: 'Ok' }))
      .catch(err =>
        knex('events').insert({ type: 'register_failure', data: { message: err.message, email: email } })
          .then(() => res.status(500).json({ message: 'Invalid registration' })));
  }

  // Allow renewal if the user is in users and pw_hash != null
  function forgotPassword(req, res) {
    const email = req.body.email;
    let user = null;
    knex('users').whereRaw('settings->>\'email_address\' = ?', [email]).first()
      .then(item => {
        user = item;
        if (!user) {
          throw new Error('No such email address');
        }
        if (user.pw_hash == null) {
          throw new Error('User not registered');
        }
        return knex('reset_password_request').where({ user_id: user.id }).whereRaw('created_at > NOW() - INTERVAL \'1 day\'').first();
      })
      .then(reg_item => {
        if (reg_item == null) {
          const uniqueToken = crypto.randomBytes(48).toString('hex');
          emails.sendRenewPasswordEmail(email, uniqueToken);
          return knex('reset_password_request').insert({ user_id: user.id, url_token: uniqueToken });
        }
        throw new Error('Already pending');
      })
      .then(() => knex('events').insert({ type: 'renew_password', data: { email: email } }))
      .then(() => res.json({ status: 'Ok' }))
      .catch(err =>
        knex('events').insert({ type: 'forgotPassword_failure', data: { message: err.message, email: email } })
          .then(() => res.status(500).json({ message: 'Invalid renewal' })));
  }

  // 1. Check if there is a valid token
  // 2. If there is, init the password and delete the token
  function initPassword(req, res) {
    const token = req.body.token;
    const password = req.body.password;
    const password2 = req.body.password2;
    let user_id = null;

    knex('reset_password_request').where({ url_token: token }).whereRaw('created_at > NOW() - INTERVAL \'1 day\'').first()
      .then(item => {
        if (!item) {
          throw new Error('No such token');
        }
        if (password !== password2) {
          throw new Error('Passwords don\'t match');
        }
        user_id = item.user_id;
        const newHash = bcrypt.hashSync(password);
        return knex('users').where({ id: user_id }).update({ pw_hash: newHash });
      })
      .then(() => knex('reset_password_request').where({ url_token: token }).del())
      .then(() => knex('events').insert({ type: 'init_password', data: { user_id: user_id } }))
      .then(() => res.json({ status: 'Ok' }))
      .catch(err =>
        knex('events').insert({ type: 'initPassword_failure', data: { message: err.message, token: token } })
          .then(() => res.json({ message: 'Invalid renewal' })));
  }

  return {
    login,
    logout,
    changePassword,
    register,
    forgotPassword,
    initPassword,
  };
};
