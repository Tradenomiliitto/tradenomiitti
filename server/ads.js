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

    return util
      .userForSession(req)
      .then(user =>
        knex('ads').insert(
          {
            user_id: user.id,
            data: req.body,
          },
          ['user_id', 'id']
        )
      )
      .then(insertResp =>
        knex('events').insert(
          {
            type: 'create_ad',
            data: { user_id: insertResp[0].user_id, ad_id: insertResp[0].id },
          },
          'data'
        )
      )
      .then(insertResp => res.json(insertResp[0].ad_id))
      .catch(next);
  }

  function getAd(req, res, next) {
    return Promise.all([
      knex('ads').where({ id: req.params.id }),
      util.loggedIn(req),
    ])
      .then(([ads, loggedIn]) => {
        if (ads.length) {
          return util.formatAd(ads[0], loggedIn);
        }
        throw new Error('No such ad id!');
      })
      .then(ad => res.send(ad))
      .catch(e => next({ status: 404, msg: e }));
  }

  function listAds(req, res, next) {
    util
      .loggedIn(req)
      .then(loggedIn =>
        service.listAds(
          loggedIn,
          req.query.limit,
          req.query.offset,
          req.query.domain,
          req.query.position,
          req.query.location,
          req.query.order,
          req.query.hide_job_ads
        )
      )
      .then(ads => res.send(ads))
      .catch(next);
  }

  function createAnswer(req, res, next) {
    if (!req.session || !req.session.id) {
      return res.sendStatus(403);
    }

    const ad_id = req.params.id;

    return Promise.all([
      knex('ads')
        .where({ id: ad_id })
        .first(),
      util.userForSession(req),
    ])
      .then(([ad, user]) =>
        Promise.all([
          knex('answers').insert(
            {
              user_id: user.id,
              ad_id,
              data: req.body,
            },
            ['id', 'user_id']
          ),
          util
            .userById(ad.user_id)
            .then(dbUser =>
              dbUser.id !== user.id
                ? emails.sendNotificationForAnswer(dbUser, ad)
                : Promise.resolve(null)
            )
            .catch(e => {
              console.error('Error sending email for answer', e);
              return Promise.resolve(null); // don't crash on failing email
            }),
        ])
      )
      .then(([insertResp]) =>
        knex('events').insert(
          {
            type: 'create_answer',
            data: {
              answer_id: insertResp[0].id,
              user_id: insertResp[0].user_id,
            },
          },
          'data'
        )
      )
      .then(data => res.json(`${data[0].answer_id}`))
      .catch(next);
  }

  function findRowUserCanDelete(req, table) {
    return util.userForSession(req).then(user =>
      sebacon.isAdmin(user.remote_id).then(isAdmin => {
        if (isAdmin) {
          return knex(table).where({
            id: req.params.id,
          });
        }
        return knex(table).where({
          user_id: user.id, // if it's not their own row, don't delete it
          id: req.params.id,
        });
      })
    );
  }

  function deleteRow(req, res, next, table) {
    findRowUserCanDelete(req, table)
      .then(rows => {
        if (rows.length === 1) {
          return Promise.all([
            knex(table)
              .where('id', rows[0].id)
              .del(),
            knex('events').insert({
              type: 'delete_content',
              data: { table: table, id: rows[0].id, user_id: rows[0].user_id },
            }),
          ]);
        }
        return Promise.reject(`Did not find row in ${table} to delete`);
      })
      .then(() => res.json('Ok'))
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
    const getAnswers = knex('answers')
      .where('user_id', req.params.id)
      .select('ad_id')
      .distinct()
      .then(results => results.map(o => o.ad_id));

    const getAdsForAnswerer = getAnswers.then(ad_ids =>
      knex('ads').whereIn('id', ad_ids)
    );
    return Promise.all([getAds, getAdsForAnswerer, util.loggedIn(req)])
      .then(([adsAsAsker, adsAsAnswerer, loggedIn]) => {
        const allAds = adsAsAsker.concat(adsAsAnswerer);
        return Promise.all(allAds.map(ad => util.formatAd(ad, loggedIn)));
      })
      .then(ads => ads.sort(service.latestFirst))
      .then(ads => res.send(ads))
      .catch(next);
  }

  return {
    createAd,
    getAd,
    deleteAd,
    listAds,
    createAnswer,
    deleteAnswer,
    adsForUser,
  };
};
