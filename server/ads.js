
module.exports = function initialize(params) {
  const util = params.util;
  const knex = params.knex;

  //comparing function for two objects with createdAt datestring field. Latest will come first.
  function latestFirst(a, b) {
    const date1 = new Date(a.created_at);
    const date2 = new Date(b.created_at);
    return date2 - date1;
  }

  function formatAd(ad, user) {
    return Promise.all([
      knex('answers').where({ad_id: ad.id})
        .then(answers => Promise.all(answers.map(formatAnswer))),
      knex('users').where({id: ad.user_id}).then(rows => rows[0])
    ]).then(function ([answers, askingUser]) {
      ad.created_by = util.formatUser(askingUser);
      ad.answers = user ? answers : answers.length;
      return ad;
    })
  }

  function formatAnswer(answer) {
    return knex('users').where({ id: answer.user_id })
      .then(rows => rows[0])
      .then(function(user) {
        answer.created_by = util.formatUser(user);
        answer.data.content = answer.data.content || '';
        return answer;
      })
  }

  function createAd(req, res) {
    if (!req.session || !req.session.id) {
      return res.sendStatus(403);
    }

    return util.userForSession(req)
      .then(user => {
        return knex('ads').insert({
          user_id: user.id,
          data: req.body
        }, 'id');
      }).then(insertResp => res.json(insertResp[0]));
  }

  function getAd(req, res) {
    return Promise.all([
      knex('ads').where({id: req.params.id}).first(),
      util.userForSession(req)
    ]).then(([ad, user]) => formatAd(ad, user))
      .then(ad => res.send(ad))
      .catch(e => { console.error(e); res.sendStatus(404) });
  }

  function listAds(req, res) {
    return Promise.all([
      knex('ads').where({}),
      util.userForSession(req)
    ]).then(([rows, user]) => Promise.all(rows.map(ad => formatAd(ad, user))))
      .then(ads => ads.sort(latestFirst))
      .then(ads => res.send(ads))
  }

  function createAnswer(req, res) {
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
      return knex('answers').insert({
        user_id: user.id,
        ad_id,
        data: req.body
      }, 'id');
    }).then(insertResp => res.json(`${insertResp[0]}`))
      .catch(err => {
        console.error('Error in /api/ilmoitukset/:id/vastaus', err);
        res.sendStatus(500);
      });
  }

  function adsForUser(req, res) {
    const getAds = knex('ads').where('user_id', req.params.id);
    const getAnswers = knex('answers').where('user_id', req.params.id).select('ad_id').distinct()
          .then(results => results.map(o => o.ad_id));

    const getAdsForAnswerer = getAnswers.then(adIds => {
      return knex('ads').whereIn('id', adIds);
    });
    return Promise.all([
      getAds,
      getAdsForAnswerer,
      util.userForSession(req)
    ]).then(([adsAsAsker, adsAsAnswerer, user]) => {
      const allAds = adsAsAsker.concat(adsAsAnswerer)
      return Promise.all(allAds.map(ad => formatAd(ad, user)))
    }).then(ads => ads.sort(latestFirst))
      .then(ads => res.send(ads))
      .catch(err => {
        console.error(err);
        res.sendStatus(500);
      })
  }

  return {
    createAd,
    getAd,
    listAds,
    createAnswer,
    adsForUser
  };
}
