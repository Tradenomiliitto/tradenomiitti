module.exports = function initialize(params) {
  const knex = params.knex;

  function userForSession(req) {
    if (!req.session.id) return Promise.reject('Request has no session id');
    return knex('sessions')
      .where({ id: req.session.id })
      .then(resp => resp.length === 0 ? Promise.reject('No session found') : resp[0].user_id)
      .then(id => knex('users').where({ id }))
      .then(resp => resp[0]);
  }

  function userById(id) {
    return knex('users').where({ id }).then(resp => (resp[0]));
  }

  function loggedIn(req) {
    return userForSession(req)
      .then(_ => true)
      .catch(_ => false);
  }

  //formats user as json. loggedIn parameter decides if users name is shown in the json
  function formatUser(user, loggedIn) {
    const formattedUser = {};
    formattedUser.id = user.id;
    const userData = user.data;
    formattedUser.name = loggedIn ? (userData.name || '') : 'Tradenomi';
    formattedUser.description = userData.description || '';
    formattedUser.title = userData.title || 'Ei titteliä';
    formattedUser.domains = userData.domains || [];
    formattedUser.positions = userData.positions || [];
    formattedUser.location = userData.location || "";
    formattedUser.profile_creation_consented = userData.profile_creation_consented || false;
    return formattedUser;
  }

  return  {
    userForSession,
    userById,
    formatUser,
    loggedIn
  };
}
