module.exports = function initialize(params) {
  const knex = params.knex;
  const util = params.util;

  function listAds(loggedIn, limit, offset) {
    let query = knex('ads').where({}).orderBy('created_at', 'desc');
    if (limit !== undefined) query = query.limit(limit);
    if (offset !== undefined) query = query.offset(offset);
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
