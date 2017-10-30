module.exports = function initialize(params) {
  const knex = params.knex;
  const util = params.util;

  function listAds(loggedIn, limit, offset, domain, position, location, order, hide_job_ads) {
    let query = knex('ads');
    const answers = knex('answers');

    switch (order) {
      case 'created_at_asc':
        query.orderBy('created_at', 'asc');
        break;
      case 'answers_desc':
        // Ads with most answers first. If equal, newest first.
        answers.select('ad_id').count('* as count').groupBy('ad_id').as('answers');
        query.leftOuterJoin(answers, 'answers.ad_id', 'ads.id').orderByRaw('count DESC NULLS LAST').orderBy('created_at', 'desc');
        break;
      case 'answers_asc':
        // Ads with least answers first. If equal, newest first.
        answers.select('ad_id').count('* as count').groupBy('ad_id').as('answers');
        query = query.leftOuterJoin(answers, 'answers.ad_id', 'ads.id').orderByRaw('count ASC NULLS FIRST').orderBy('created_at', 'desc');
        break;
      case 'newest_answer_desc':
        // Ads with the newest answer first. If equal, newest first.
        answers.select('ad_id').max('created_at as newest_answer').groupBy('ad_id').as('answers');
        query.leftOuterJoin(answers, 'answers.ad_id', 'ads.id').orderByRaw('newest_answer DESC NULLS LAST').orderBy('created_at', 'desc');
        break;
      case 'created_at_desc':
      default:
        query.orderBy('created_at', 'desc');
        break;
    }

    if (limit !== undefined) query.limit(limit);
    if (offset !== undefined) query.offset(offset);
    if (domain !== undefined) {
      query.whereRaw("data->>'domain' = ?", [domain]);
    }
    if (position !== undefined) {
      query.whereRaw("data->>'position' = ?", [position]);
    }
    if (location !== undefined) {
      query.whereRaw("data->>'location' = ?", [location]);
    }
    if (hide_job_ads && hide_job_ads === 'true') {
      query.whereRaw("data->>'is_job_ad' <> 'true' or data->'is_job_ad' is null");
    }
    return query
      .then(rows => Promise.all(rows.map(ad => util.formatAd(ad, loggedIn))));
  }

  function latestFirst(a, b) {
    const date1 = new Date(a.created_at);
    const date2 = new Date(b.created_at);
    return date2 - date1;
  }

  return {
    listAds,
    latestFirst,
  };
};
