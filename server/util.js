module.exports = function initialize(params) {
  const knex = params.knex;

  function userForSession(req) {
    if (!req.session.id) return Promise.resolve(null);
    return knex('sessions')
      .where({ id: req.session.id })
      .then(resp => resp.length === 0 ? Promise.reject('No session found') : resp[0].user_id)
      .then(id => knex('users').where({ id }))
      .then(resp => resp[0]);
  }

  function formatUser(user) {
    const formattedUser = user.data;
    formattedUser.id = user.id;
    const userData = user.data;

    formattedUser.name = userData.name || '';
    formattedUser.description = userData.description || '';
    formattedUser.primary_domain = userData.primary_domain || 'Ei valittua toimialaa';
    formattedUser.primary_position = userData.primary_position || 'Ei titteliä';
    formattedUser.domains = userData.domains || [];
    formattedUser.positions = userData.positions || [];
    formattedUser.profile_creation_consented = userData.profile_creation_consented || false;

    return formattedUser;
  }


  return  {
    userForSession,
    formatUser
  };
}
