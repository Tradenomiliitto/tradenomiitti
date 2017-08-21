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
          const pw_hash = user.pw_hash;
          return bcrypt.compare(password, pw_hash);
        }
        throw new Error('Invalid login');
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
            // return res.redirect(req.query.path || '/');
          });
        }
        throw new Error('Invalid login');
      })
      .catch(err => knex('events').insert({ type: 'login_failure', data: { error: err.message, email } })
        .then(() => res.status(500).json({ status: 'Failure', message: 'Login failed' }))
        // .then(() => res.status(403).send('Jotain meni pieleen'))
      );
  }

  // Can be cleaned if no events needed for test user logouts
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
          if (isValid) {
            if (newPassword === newPassword2) {
              // Change password here
              const newHash = bcrypt.hashSync(newPassword);
              return knex('users').where({ id: user.id }).update({ pw_hash: newHash })
                .then(() => knex('events').insert({ type: 'change_password_success', data: { user_id: user.id } }))
                .then(() => res.status(200).json({ status: 'Ok' }));
            }
            return knex('events').insert({ type: 'change_password_failure', data: { message: 'No match', user_id: user.id } })
              .then(() => res.status(500).json({ status: 'Passwords don\'t match' }));
          }
          return knex('events').insert({ type: 'change_password_failure', data: { message: 'Wrong old password', user_id: user.id } })
            .then(() => res.status(403).json({ status: 'Wrong old password' }));
        })
        .catch(next);
    }

    // No session id
    return knex('events').insert({ type: 'logout_failure', data: { message: 'no_session_id' } })
      .then(() => res.redirect('/'));
  }

  // 1. Emailaddr belongs to a valid YA-member (email addr in users)
  // 2. Emailaddr already in use (pw_hash != null)
  // 3. PW email already sent and valid?
  // 4. Send PW email
  function register(req, res) {
    const email = req.body.email;
    let user = null;
    knex('users').whereRaw('settings->>\'email_address\' = ?', [email]).first()
      .then(item => {
        user = item;
        if (user && user.pw_hash == null) {
          return knex('registration').where({ user_id: user.id }).whereRaw('created_at > NOW() - INTERVAL \'1 hour\'').first();
        }
        throw new Error('No such user');
      })
      .then(reg_item => {
        if (reg_item == null) {
          const uniqueToken = crypto.randomBytes(48).toString('hex');
          emails.sendRegistrationEmail(email, uniqueToken);
          return knex('registration').insert({ user_id: user.id, url_token: uniqueToken });
        }
        throw new Error('Already pending');
      })
      .then(() => res.json({ status: 'Ok' }))
      .catch(err => res.status(500).json({ message: err.message }));
  }

  // 1. Check if there is a valid token
  // 2. If there is, init the password and delete the token
  function initPassword(req, res) {
    const token = req.body.token;
    const password = req.body.password;
    const password2 = req.body.password2;


    knex('registration').where({ url_token: token }).whereRaw('created_at > NOW() - INTERVAL \'1 hour\'').first()
      .then(item => {
        if (!item) {
          throw new Error('Invalid payload');
        }
        if (password !== password2) {
          throw new Error('Passwords don\'t match');
        }
        const newHash = bcrypt.hashSync(password);
        return knex('users').where({ id: item.user_id }).update({ pw_hash: newHash });
      })
      .then(() => knex('registration').where({ url_token: token }).del())
      .then(() => res.json({ status: 'Ok' }))
      .catch(err => res.json({ message: err.message }));
  }

  return {
    login,
    logout,
    changePassword,
    register,
    initPassword,
  };
};
