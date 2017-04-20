module.exports = function initialize(params) {
  const knex = params.knex;
  const util = params.util;

  function listProfiles(loggedIn, limit, offset, domain, position, location, order) {
    let query = knex('users').where({}).select('users.*');
    if (limit !== undefined) query = query.limit(limit);
    if (offset !== undefined) query = query.offset(offset);
    if (domain !== undefined) {
      query = query.whereExists(function () {
        this.select('user_id')
          .from('skills')
          .whereRaw('users.id = skills.user_id and heading = ? and type = ?',
                    [domain, 'domain'])
      });
    }
    if (position !== undefined) {
      query = query.whereExists(function () {
        this.select('user_id')
          .from('skills')
          .whereRaw('users.id = skills.user_id and heading = ? and type = ?',
                    [position, 'position'])
      });
    }
    if (location !== undefined) {
      query = query.whereRaw("data->>'location' = ?", [ location ])
    }

    if (order === undefined || order === 'recent') {
      query = query
        .leftOuterJoin('ads', 'users.id', 'ads.user_id')
        .leftOuterJoin('answers', 'users.id', 'answers.user_id')
        .groupBy('users.id')
        .orderByRaw('greatest(max(ads.created_at), max(answers.created_at), users.modified_at) desc nulls last')
    }

    return query
      .then(resp => {
        return resp.map(user => util.formatUser(user, loggedIn));
      })
  }

  function profileSkills(user_id) {
    return knex('skills').where({ user_id });
  }

  return {
    listProfiles,
    profileSkills
  }
};
