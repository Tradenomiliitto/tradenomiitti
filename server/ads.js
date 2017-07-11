
module.exports = function initialize(params) {
  const util = params.util;
  const knex = params.knex;
  const emails = params.emails;
  const service = require('./services/ads')({ knex, util });
  const sebacon = params.sebacon;

  function createAd(req, res, next) {
    if (!req.session || !req.session.id) {
      return res.sendStatus(403);
    }

    return util.userForSession(req)
      .then(user => {
        return knex('ads').insert({
          user_id: user.id,
          data: req.body
        }, 'id');
      }).then(insertResp => res.json(insertResp[0]))
      .catch(next)
  }

  function getAd(req, res, next) {
    return Promise.all([
      knex('ads').where({id: req.params.id}).first(),
      util.loggedIn(req)
    ]).then(([ad, loggedIn]) => util.formatAd(ad, loggedIn))
      .then(ad => res.send(ad))
      .catch(e => next({ status: 404, msg: e}));
  }

  function listAds(req, res, next) {
    util.loggedIn(req)
      .then(loggedIn => service.listAds(
        loggedIn,
        req.query.limit,
        req.query.offset,
        req.query.domain,
        req.query.position,
        req.query.location,
        req.query.order
      ))
      .then(ads => res.send(ads))
      .catch(next)
  }

  function createAnswer(req, res, next) {
    if (!req.session || !req.session.id) {
      return res.sendStatus(403);
    }

    const ad_id = req.params.id;

    return Promise.all([
      knex('ads').where({ id: ad_id }).first(),
      knex('answers').where({ ad_id }),
      util.userForSession(req)
    ]).then(([ad, answers, user]) => {

      const isAsker = ad.user_id === user.id;
      if (isAsker) return Promise.reject('User tried to answer own question');

      const alreadyAnswered = answers.some(a => a.user_id === user.id)
      if (alreadyAnswered) return Promise.reject('User tried to answer several times');
      return Promise.all([
        knex('answers').insert({
          user_id: user.id,
          ad_id,
          data: req.body
        }, 'id'),
        util.userById(ad.user_id).then(dbUser => {
          emails.sendNotificationForAnswer(dbUser, ad);
        }).catch(e => {
          console.error('Error sending email for answer', e);
          return Promise.resolve(null); // don't crash on failing email
        })
      ]);
    }).then(([ insertResp, emailResp ]) => {
      res.json(`${insertResp[0]}`);
    }).catch(next);
  }

  function findRowUserCanDelete(req, table) {
    return util.userForSession(req).then(user => {
      return sebacon.isAdmin(user.remote_id).then(isAdmin => {
        if (isAdmin)
          return knex(table).where({
            id: req.params.id
          });
        else
          return knex(table).where({
            user_id: user.id, // if it's not their own row, don't delete it
            id: req.params.id
        });
      })
    })
  }

  function deleteRow(req, res, next, table) {
    findRowUserCanDelete(req, table)
      .then(rows => {
        if (rows.length === 1) {
          return knex(table).where('id', rows[0].id).del();
        } else {
          return Promise.reject(`Did not find row in ${table} to delete`);
        }
      }).then(() => res.json('Ok'))
      .catch(next);
  }

  function deleteAd(req, res, next) {
    deleteRow(req, res, next, 'ads');
  }

  function deleteAnswer(req, res, next) {
    deleteRow(req, res, next, 'answers');
  }

  function adsForUser(req, res, next) {
    const getAds = knex('ads').where('user_id', req.params.id);
    const getAnswers = knex('answers').where('user_id', req.params.id).select('ad_id').distinct()
          .then(results => results.map(o => o.ad_id));

    const getAdsForAnswerer = getAnswers.then(adIds => {
      return knex('ads').whereIn('id', adIds);
    });
    return Promise.all([
      getAds,
      getAdsForAnswerer,
      util.loggedIn(req)
    ]).then(([adsAsAsker, adsAsAnswerer, loggedIn]) => {
      const allAds = adsAsAsker.concat(adsAsAnswerer)
      return Promise.all(allAds.map(ad => util.formatAd(ad, loggedIn)))
    }).then(ads => ads.sort(service.latestFirst))
      .then(ads => res.send(ads))
      .catch(next)
  }

  return {
    createAd,
    getAd,
    deleteAd,
    listAds,
    createAnswer,
    deleteAnswer,
    adsForUser
  };
}
