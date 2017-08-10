const uuid = require('uuid');
const request = require('request');
const bcrypt = require('bcryptjs');

module.exports = function initialize(params) {
  const { knex, util } = params;

  function login(req, res, next) {
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
        return Promise.reject(new Error('Invalid login'));
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
            return res.redirect(req.query.path || '/');
          });
        }
        return Promise.reject(new Error('Invalid login'));
      })
      .catch(err => knex('events').insert({ type: 'login_failure', data: { error: err.message, email } })
        // .then(() => res.status(500).send('Jotain meni pieleen'))
        .then(() => res.status(403).send('Jotain meni pieleen'))
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
    let sessionId;
    const oldPassword = req.body.oldPassword;
    const newPassword = req.body.newPassword;
    const newPassword2 = req.body.newPassword2;
    let user;

    if (req.session.id) {
      sessionId = req.session.id;
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

  return {
    login,
    logout,
    changePassword,
  };
};
