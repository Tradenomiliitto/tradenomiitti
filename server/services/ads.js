module.exports = function initialize(params) {
  const knex = params.knex;
  const util = params.util;

  function listAds(loggedIn) {
    return knex('ads').where({})
      .then(rows => Promise.all(rows.map(ad => util.formatAd(ad, loggedIn))))
      .then(ads => ads.sort(latestFirst))
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
