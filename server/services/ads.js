module.exports = function initialize(params) {
  const knex = params.knex;
  const util = params.util;

  function listAds(loggedIn, limit, offset, domain, position, location) {
    let query = knex('ads').where({}).orderBy('created_at', 'desc');
    if (limit !== undefined) query = query.limit(limit);
    if (offset !== undefined) query = query.offset(offset);
    if (domain !== undefined) {
      query = query.whereRaw("data->>'domain' = ?", [ domain ])
    }
    if (position !== undefined) {
      query = query.whereRaw("data->>'position' = ?", [ position ])
    }
    if (location !== undefined) {
      query = query.whereRaw("data->>'location' = ?", [ location ])
    }
    return query
      .then(rows => Promise.all(rows.map(ad => util.formatAd(ad, loggedIn))))
  }

  function latestFirst(a, b) {
    const date1 = new Date(a.created_at);
    const date2 = new Date(b.created_at);
    return date2 - date1;
  }

  return {
    listAds,
    latestFirst
  };
}
