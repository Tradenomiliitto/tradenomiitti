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
      const user = {};
      user.extra = {
        first_name: firstname,
        nick_name: nickname,
        positions: positions,
        domains: domains
      }
      user.ads = ads;

      const userData = databaseUser.data;
      user.name = userData.name || '';
      user.description = userData.description || '';
      user.primary_domain = userData.primary_domain || 'Ei valittua toimialaa';
      user.primary_position = userData.primary_position || 'Ei titteliä';
      user.domains = userData.domains || [];
      user.positions = userData.positions || [];
      user.profile_creation_consented = userData.profile_creation_consented || false;

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

function userAds(user) {
  return knex('ads')
    .where({ user_id: user.id });
}


module.exports = {
  getMe,
  putMe,
  initialize
};
