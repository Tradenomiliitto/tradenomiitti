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
  return Promise.all([
    knex('ads').where({id: req.params.id}).first(),
    util.userForSession(req)
  ]).then(([ad, user]) => formatAd(ad, user))
    .then(ad => res.send(ad))
    .catch(e => { console.error(e); res.sendStatus(404) });
})

app.get('/api/ads', (req, res) => {
  return Promise.all([
    knex('ads').where({}),
    util.userForSession(req)
  ]).then(([rows, user]) => Promise.all(rows.map(ad => formatAd(ad, user))))
    .then(ads => ads.sort(latestFirst))
    .then(ads => res.send(ads))
})

//comparing function for two objects with createdAt datestring field. Latest will come first.
function latestFirst(a, b) {
  date1 = new Date(a.created_at);
  date2 = new Date(b.created_at);
  return date2 - date1;
}

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


function formatAd(ad, user) {
  return Promise.all([
    knex('answers').where({ad_id: ad.id})
      .then(answers => Promise.all(answers.map(formatAnswer))),
    knex('users').where({id: ad.user_id}).then(rows => rows[0])
  ]).then(function ([answers, askingUser]) {
    ad.created_by = formatUser(askingUser);
    ad.answers = user ? answers : answers.length;
    return ad;
  })
}

function formatAnswer(answer) {
  return knex('users').where({ id: answer.user_id })
    .then(rows => rows[0])
    .then(function(user) {
      answer.created_by = formatUser(user);
      answer.data.content = answer.data.content || '';
      return answer;
    })
}

function formatUser(user) {
  formattedUser = user.data;
  formattedUser.id = user.id;
  return formattedUser;
}

app.get('*', (req, res) => {
  res.sendFile('./index.html', {root: rootDir})
});

app.listen(3000, () => {
  console.log('Listening on 3000');
});

