module.exports = function initialize(params) {
  const knex = params.knex;
  const util = params.util;

  function listProfiles(loggedIn, limit, offset) {
    let query = knex('users').where({});
    if (limit !== undefined) query = query.limit(limit);
    if (offset !== undefined) query = query.offset(offset);
    return query
      .then(resp => {
        return resp.map(user => util.formatUser(user, loggedIn));
      })
  }
  return {
    listProfiles
  }
};
