let knex, sebacon, util;

function initialize(params) {
  knex = params.knex;
  sebacon = params.sebacon;
  util = params.util;
}

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
        userAds(user),
        user
      ])
    })
    .then(([ firstname, nickname, { positions, domains }, ads, databaseUser ]) => {
      const user = util.formatUser(databaseUser);
      user.extra = {
        first_name: firstname,
        nick_name: nickname,
        positions: positions,
        domains: domains
      }
      user.ads = ads;

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
      console.log(user)
      return knex('users')
        .where({ id: user.id })
        .update('data', user.data)
    }).then(resp => {
      res.sendStatus(200);
    }).catch(err => {
      console.error(err);
      res.sendStatus(500);
    });
}

function userAds(user) {
  return knex('ads')
    .where({ user_id: user.id });
}


module.exports = {
  getMe,
  putMe,
  consentToProfileCreation,
  initialize
};
