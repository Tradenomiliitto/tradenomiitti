const express = require('express');
const bodyParser = require('body-parser');
const uuid = require('uuid');
const request = require('request');
const cookieSession = require('cookie-session');

const sebacon = require('./sebaconService');
const logon = require('./logonHandling');
const util = require('./util');
const profile = require('./profile');

const rootDir = "./frontend"

const app = express();

// knex
const knex_config = require('../knexfile.js');
const knex = require('knex')(knex_config[process.env.environment]);
knex.migrate.latest(knex_config[process.env.environment]);

//serve static files if developing locally (this route is not reached on servers)
app.use('/static', express.static(rootDir + '/static'));


const secret = process.env.NON_LOCAL ? process.env.COOKIE_SECRET : 'local';

app.use(cookieSession({
  name: 'session',
  secret: secret,
  httpOnly: true,
  secure: process.env.NON_LOCAL,
  maxAge: 365 * 24 * 60 * 60 * 1000
}));

if (process.env.NON_LOCAL) {
  app.set('trust proxy', 'loopback');
}

app.get('/api/user/:id', (req, res) => {
  knex('users').where('id', req.params.id)
    .then(function(rows){
      if(rows.length === 0){
         return Promise.reject("Not Found");
      }
      else return rows;
    })
    .then(rows => res.send(rows[0]))
    .catch(e => res.sendStatus(404))
});

const communicationsKey = process.env.COMMUNICATIONS_KEY;
if (!communicationsKey) console.warn("You should have COMMUNICATIONS_KEY for avoine in ENV");

const sebaconAuth = process.env.SEBACON_AUTH;
const sebaconCustomer = process.env.SEBACON_CUSTOMER;
const sebaconUser = process.env.SEBACON_USER;
const sebaconPassword = process.env.SEBACON_PASSWORD;
if (!sebaconAuth ||
    !sebaconCustomer ||
    !sebaconUser ||
    !sebaconPassword) {
  console.warn("You should have SEBACON_* parameters for avoine in ENV");
}

sebacon.initialize({ customer: sebaconCustomer, user: sebaconUser,
                     password: sebaconPassword, auth: sebaconAuth});

logon.initialize({ communicationsKey, knex, sebacon });
util.initialize({ knex });
profile.initialize({ knex, sebacon, util});

const urlEncoded = bodyParser.urlencoded();
const jsonParser = bodyParser.json();

app.post('/login', urlEncoded, logon.login );

app.get('/logout', logon.logout);

app.get('/api/me', profile.getMe);

app.put('/api/me', jsonParser, profile.putMe);

app.get('/api/positions', (req, res) => {
  return sebacon.getPositionTitles().then(positions => res.json(Object.values(positions)));
});

app.get('/api/domains', (req, res) => {
  return sebacon.getDomainTitles().then(domains => res.json(Object.values(domains)));
});

app.post('/api/ad', jsonParser, (req, res) => {
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
});

app.get('/api/ads/:id', (req, res) => {
  return knex('ads').where({id: req.params.id})
    .then(rows => rows[0])
    .then(ad => formatAd(ad))
    .then(ad => res.send(ad))
    .catch(e => res.sendStatus(404));
})

app.get('/api/ads', (req, res) => {
  return knex('ads').where({})
    .then(rows => Promise.all(rows.map(formatAd)))
    .then(ads => res.send(ads))
})

app.post('/api/ads/:id/answer', jsonParser, (req, res) => {
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
      console.error('Error in /api/ads/:id/answer', err);
      res.sendStatus(500);
    });
});


function formatAd(ad) {
  return Promise.all([
    knex('answers').where({ad_id: ad.id})
      .then(answers => Promise.all(answers.map(formatAnswer))),
    knex('users').where({id: ad.user_id}).then(rows => rows[0])
  ]).then(function ([answers, user]) {
    ad.created_by = user;
    ad.answers = answers;
    return ad;
  })
}

function formatAnswer(answer) {
  return knex('users').where({ id: answer.user_id })
    .then(rows => rows[0])
    .then(function(user) {
      answer.created_by = user;
      return answer;
    })
}

app.get('*', (req, res) => {
  res.sendFile('./index.html', {root: rootDir})
});

app.listen(3000, () => {
  console.log('Listening on 3000');
});

