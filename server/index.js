const express = require('express');
const bodyParser = require('body-parser');
const uuid = require('uuid');
const request = require('request');
const cookieSession = require('cookie-session');

const rootDir = "./frontend"

const app = express();

// knex
const knex_config = require('../knexfile.js');
const knex = require('knex')(knex_config[process.env.environment]);
knex.migrate.latest(knex_config[process.env.environment]);

//serve static files if developing locally
if(process.env.environment === "local"){
  app.use('/static', express.static(rootDir + '/static'));
}


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

if (!communicationsKey) {
  console.warn("You should have COMMUNICATIONS_KEY for avoine in ENV");
}

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
          return knex('users')
            .insert({ remote_id: body.result.id })
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
          return res.send(`Hei ${body.result.name}, olet kirjautunut onnistuneesti`);
        });
      })
  });
});

app.get('/api/me', (req, res) => {
  if (!req.session || !req.session.id) {
    return res.sendStatus(403);
  }

  return knex('sessions')
    .where({ id: req.session.id })
    .then(resp => resp[0].user_id)
    .then(id => knex('users').where({ id }))
    .then(resp => res.json(resp[0]));
});

app.get('*', (req, res) => {
  res.sendFile('./index.html', {root: rootDir})
});

app.listen(3000, () => {
  console.log('Listening on 3000');
});
