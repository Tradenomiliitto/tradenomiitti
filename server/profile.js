
module.exports = function initialize(params) {
  const knex = params.knex;
  const sebacon = params.sebacon;
  const util = params.util;

  function getMe(req, res) {
    if (!req.session || !req.session.id) {
      return res.sendStatus(403);
    }
    return util.userForSession(req)
      .then(user => {
        return Promise.all([
          sebacon.getUserFirstName(user.remote_id),
          sebacon.getUserNickName(user.remote_id),
          sebacon.getUserEmploymentExtras(user.remote_id),
          user
        ])
      })
      .then(([ firstname, nickname, { positions, domains }, databaseUser ]) => {
        const user = util.formatUser(databaseUser);
        user.extra = {
          first_name: firstname,
          nick_name: nickname,
          positions: positions,
          domains: domains
        }

        return res.json(user);
      })
      .catch((err) => {
        console.error('Error in /api/me', err);
        req.session = null;
        res.sendStatus(500);
      });
  }

  function putMe(req, res) {
    if (!req.session || !req.session.id) {
      return res.sendStatus(403);
    }

    return util.userForSession(req)
      .then(user => {
        return knex('users').where({ id: user.id }).update('data', req.body)
      }).then(resp => {
        res.sendStatus(200);
      }).catch(err => {
        console.error(err);
        res.sendStatus(500);
      })
  }

  function consentToProfileCreation(req, res) {
    if (!req.session || !req.session.id) {
      return res.sendStatus(403);
    }

    return util.userForSession(req)
      .then(user => {
        // patch user object
        Object.assign(user.data, {profile_creation_consented: true});
        return knex('users')
          .where({ id: user.id })
          .update('data', user.data)
      }).then(resp => {
        res.sendStatus(200);
      }).catch(err => {
        console.error('Error in /api/profiilit/luo', err);
        res.sendStatus(500);
      });
  }

  function listProfiles(req, res) {
    return knex('users').where({})
      .then(resp => {
        return resp.map(user => util.formatUser(user));
      }).then(users => res.json(users))
      .catch(err => {
        console.error(err);
        res.sendStatus(500);
      })
  }

  function getProfile(req, res) {
    return knex('users').where('id', req.params.id).first()
      .then(user => util.formatUser(user))
      .then(user => res.json(user))
      .catch(err => {
        return res.sendStatus(404)
      });
  }

  return {
    getMe,
    putMe,
    consentToProfileCreation,
    listProfiles,
    getProfile
  };
}
