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

const sebacon = require('./sebaconService')({
  customer: sebaconCustomer, user: sebaconUser,
  password: sebaconPassword, auth: sebaconAuth});

const logon = require('./logonHandling')({ communicationsKey, knex, sebacon });
const util = require('./util')({ knex });
const profile = require('./profile')({ knex, sebacon, util});
const ads = require('./ads')({ util, knex });

const smtpHost = process.env.SMTP_HOST;
const smtpUser = process.env.SMTP_USER;
const smtpPassword = process.env.SMTP_PASSWORD;
const smtpTls = process.env.SMTP_TLS;
if (!smtpHost || !smtpUser || !smtpPassword || !smtpTls) {
  console.warn("You should have SMTP_* parameters in ENV");
}
const smtp =
      { host: smtpHost,
        user: smtpUser,
        password: smtpPassword,
        tls: smtpTls === 'true'
      }
const emails = require('./emails')({ smtp });

const urlEncoded = bodyParser.urlencoded();
const jsonParser = bodyParser.json();

app.post('/kirjaudu', urlEncoded, logon.login );
app.get('/uloskirjautuminen', logon.logout);

app.get('/api/profiilit/oma', profile.getMe);
app.put('/api/profiilit/oma', jsonParser, profile.putMe);
app.post('/api/profiilit/luo', profile.consentToProfileCreation);
app.get('/api/profiilit', profile.listProfiles);
app.get('/api/profiilit/:id', profile.getProfile);

app.get('/api/tehtavaluokat', (req, res) => {
  return sebacon.getPositionTitles().then(positions => res.json(Object.values(positions)));
});

app.get('/api/toimialat', (req, res) => {
  return sebacon.getDomainTitles().then(domains => res.json(Object.values(domains)));
});

app.post('/api/ilmoitukset', jsonParser, ads.createAd);
app.get('/api/ilmoitukset/:id', ads.getAd);
app.get('/api/ilmoitukset', ads.listAds);
app.get('/api/ilmoitukset/tradenomilta/:id', ads.adsForUser);
app.post('/api/ilmoitukset/:id/vastaus', jsonParser, ads.createAnswer);

app.get('/api/test-email-generation', (req, res) => {
  util.userForSession(req).then(user => {
    res.send(emails.send(util.formatUser(user)))
  });
});

app.get('*', (req, res) => {
  res.sendFile('./index.html', {root: rootDir})
});

app.listen(3000, () => {
  console.log('Listening on 3000');
});

