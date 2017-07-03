module.exports = function initialize(params) {
  const knex = params.knex;
  const util = params.util;

  function listAds(loggedIn, limit, offset, domain, position, location, sorting) {
    let query = knex('ads');
    let answers = knex('answers');

    switch(sorting) {
      case 'created_at_asc':
        query = query.orderBy('created_at', 'asc');
        break;
      case 'answers_desc':
        // Ads with most answers first. If equal, newest first.
        answers.select('ad_id').count('* as count').groupBy('ad_id').as('answers');
        query = query.leftOuterJoin(answers, 'answers.ad_id', 'ads.id').orderByRaw('count DESC NULLS LAST').orderBy('created_at', 'desc');
        break;
      case 'answers_asc':
        // Ads with least answers first. If equal, newest first.
        answers.select('ad_id').count('* as count').groupBy('ad_id').as('answers');
        query = query.leftOuterJoin(answers, 'answers.ad_id', 'ads.id').orderByRaw('count ASC NULLS FIRST').orderBy('created_at', 'desc');
        break;
      default:
        query = query.orderBy('created_at', 'desc');
        break;
    }

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
