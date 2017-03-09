const express = require('express');
const bodyParser = require('body-parser');
const uuid = require('uuid');
const request = require('request');
const cookieSession = require('cookie-session');

const sebacon = require('./sebaconService');
const logon = require('./logonHandling');

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

const urlEncoded = bodyParser.urlencoded();
const jsonParser = bodyParser.json();

app.post('/login', urlEncoded, logon.login );

app.get('/logout', logon.logout);

app.get('/api/me', (req, res) => {
  if (!req.session || !req.session.id) {
    return res.sendStatus(403);
  }
  return userForSession(req)
    .then(user => {
      return Promise.all([
        sebacon.getUserFirstName(user.remote_id),
        sebacon.getUserNickName(user.remote_id),
        sebacon.getUserEmploymentExtras(user.remote_id),
        userAds(user),
        user
      ])
    })
    .then(([ firstname, nickname, { positions, domains }, ads, databaseUser ]) => {
      const user = {};
      user.extra = {
        first_name: firstname,
        nick_name: nickname,
        positions: positions,
        domains: domains
      }
      user.ads = ads;

      const userData = databaseUser.data;
      user.name = userData.name || '';
      user.description = userData.description || '';
      user.primary_domain = userData.primary_domain || 'Ei valittua toimialaa';
      user.primary_position = userData.primary_position || 'Ei titteliä';
      user.domains = userData.domains || [];
      user.positions = userData.positions || [];
      user.profile_creation_consented = userData.profile_creation_consented || false;

      return res.json(user);
    })
    .catch((err) => {
      console.error('Error in /api/me', err);
      req.session = null;
      res.sendStatus(500);
    });
});

app.put('/api/me', jsonParser, (req, res) => {
  if (!req.session || !req.session.id) {
    return res.sendStatus(403);
  }

  return userForSession(req)
    .then(user => {
      return knex('users').where({ id: user.id }).update('data', req.body)
    }).then(resp => {
      res.sendStatus(200);
    }).catch(err => {
      console.error(err);
      res.sendStatus(500);
    })
});

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

  return userForSession(req)
    .then(user => {
      return knex('ads').insert({
        user_id: user.id,
        data: req.body
      }, 'id');
    }).then(insertResp => res.json(`${insertResp[0]}`));
});


app.get('*', (req, res) => {
  res.sendFile('./index.html', {root: rootDir})
});

app.listen(3000, () => {
  console.log('Listening on 3000');
});

function userForSession(req) {
  return knex('sessions')
    .where({ id: req.session.id })
    .then(resp => resp.length === 0 ? Promise.rejected('No session found') : resp[0].user_id)
    .then(id => knex('users').where({ id }))
    .then(resp => resp[0]);
}

function userAds(user) {
  return knex('ads')
    .where({ user_id: user.id });
}
