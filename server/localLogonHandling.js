const uuid = require('uuid');
const request = require('request');
const bcrypt = require('bcryptjs');

module.exports = function initialize(params) {
  const { knex, util } = params;

  function login(req, res, next) {
    const sessionId = uuid.v4();
    let user = null;
    const password = req.body.password;
    const username = req.body.username;

    return knex('users').whereRaw('data->>\'name\' = ?', [username]).first()
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
      .catch(err => knex('events').insert({ type: 'login_failure', data: { error: err.message, username } })
        .then(() => res.status(500).send('Jotain meni pieleen'))
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
      .then(() => res.redirect('/')
      );
  }

  return {
    login,
    logout,
  };
};
