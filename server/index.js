const express = require('express');
const bodyParser = require('body-parser');
const uuid = require('uuid');
const request = require('request');
const cookieSession = require('cookie-session');

const sebacon = require('./sebaconService');

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

const urlEncoded = bodyParser.urlencoded();
const jsonParser = bodyParser.json();

app.post('/login', urlEncoded, (req, res) => {
  const ssoId = req.body.ssoid;
  const validationReq = {
    id: uuid.v4(),
    method: "GetUser",
    params: [
      communicationsKey,
      ssoId
    ],
    jsonrpc: "2.0"
  };
  request.post({
    url: 'https://tunnistus.avoine.fi/mmserver',
    json: validationReq
  }, (err, response, body) => {
    if (err) {
      console.error(err);
      return res.status(500).send('Jotain meni pieleen');
    }

    if (body.error) {
      console.log(body);
      req.session = null;
      return res.status(400).send('Kirjautuminen epäonnistui');
    }

    const sessionId = uuid.v4();
    const remoteId = body.result.local_id;
    return knex('users').where({ remote_id: remoteId })
      .then((resp) => {
        if (resp.length === 0) {
          return Promise.all([
            sebacon.getUserFirstName(remoteId),
            sebacon.getUserNickName(remoteId),
            sebacon.getUserPositions(remoteId),
            sebacon.getUserDomains(remoteId)
          ]).then(([firstname, nickname, positions, domains]) => {
            return knex('users')
              .insert({
                remote_id: body.result.local_id,
                data: {
                  name: nickname || firstname,
                  domains: domains.map(d => ({ heading: d, skill_level: 1 })),
                  positions: positions.map(d => ({ heading: d, skill_level: 1 })),
                  profile_creation_consented: false
                }
              }, 'id') // postgres does not automatically return the id, ask for it explicitly
          })
            .then(insertResp => ({ id: insertResp[0] }))
        } else {
          return resp[0];
        }
      })
      .then((user) => {
        return knex('sessions').insert({
          id: sessionId,
          user_id: user.id
        }).then(() => {
          req.session.id = sessionId;
          return res.redirect(req.query.path || '/');
        });
      })
  });
});

app.get('/logout', (req, res) => {
  const sessionId = req.session.id || 'nosession';
  req.session = null;
  return knex('sessions').where({id: sessionId}).del()
    .then(() => res.redirect('https://tunnistus.avoine.fi/sso-logout/'));
});

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


function formatAd(ad) {
  return Promise.all([
    knex('answers').where({ad_id: ad.id})
      .then(answers => Promise.all(answers.map(formatAnswer))),
    knex('users').where({id: ad.user_id}).then(rows => rows[0])
  ]).then(function ([answers, user]) {
    ad.createdBy = user;
    ad.answers = answers;
    return ad;
  })
}

function formatAnswer(answer) {
  return knex('users').where({ id: answer.user_id })
    .then(rows => rows[0])
    .then(function(user) {
      answer.user = user;
      return answer;
    })
}

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
