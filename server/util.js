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

  //formats given user as json, giving only fields that current user is allowed to see
  function formatUserSafe(req, user) {
    return userForSession(req)
      .then(_ => formatUser(user))
      .catch(e => formatUserNotLoggedIn(user));
  } 

  function formatUser(user) {
    const formattedUser = user.data;
    formattedUser.id = user.id;
    const userData = user.data;
    formattedUser.name = userData.name || '';
    formattedUser.description = userData.description || '';
    formattedUser.title = userData.title || 'Ei titteliä';
    formattedUser.domains = userData.domains || [];
    formattedUser.positions = userData.positions || [];
    formattedUser.location = userData.location || "";
    formattedUser.profile_creation_consented = userData.profile_creation_consented || false;

    return formattedUser;
  }

  function formatUserNotLoggedIn(user){
    formattedUser = formatUser(user);
    formattedUser.name = 'Tradenomi';
    return formattedUser;
  }

  return  {
    userForSession,
    formatUser,
    formatUserSafe
  };
}
