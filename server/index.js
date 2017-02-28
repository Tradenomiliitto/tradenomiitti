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
    return knex('users').where({ remote_id: body.result.local_id })
      .then((resp) => {
        if (resp.length === 0) {
          // TODO get actual name and description
          return knex('users')
            // postgres does not automatically return the id, ask for it explicitly
            .insert({ remote_id: body.result.local_id, first_name: '', description: '' }, 'id')
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
        sebacon.getUserPositions(user.remote_id),
        sebacon.getUserDomains(user.remote_id),
        user
      ])
    })
    .then(([ firstname, nickname, positions, domains, user ]) => {
      // TODO not like this
      user.extra = {
        first_name: firstname,
        nick_name: nickname,
        positions: positions,
        domains: domains
      }
      return res.json(user);
    })
    .catch((err) => {
      console.error('Error in /api/me', err);
      req.session = null;
      res.sendStatus(500);
    });
});

app.get('/api/me/positions', (req, res) => {
  if (!req.session || !req.session.id) {
    return res.sendStatus(403);
  }

  return userForSession(req)
    .then(user => sebacon.getUserPositions(user.remote_id))
    .then(titles => res.json(titles));
});

app.get('/api/positions', (req, res) => {
  return sebacon.getPositionTitles().then(positions => res.json(Object.values(positions)));
});

app.get('/api/domains', (req, res) => {
  return sebacon.getDomainTitles().then(domains => res.json(Object.values(domains)));
})


app.get('*', (req, res) => {
  res.sendFile('./index.html', {root: rootDir})
});

app.listen(3000, () => {
  console.log('Listening on 3000');
});

function userForSession(req) {
  return knex('sessions')
    .where({ id: req.session.id })
    .then(resp => resp[0].user_id)
    .then(id => knex('users').where({ id }))
    .then(resp => resp[0]);
}
