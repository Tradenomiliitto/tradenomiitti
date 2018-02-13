const express = require('express');
const bodyParser = require('body-parser');
const fileUpload = require('express-fileupload');
const uuid = require('uuid');
const crypto = require('crypto');
const cookieSession = require('cookie-session');
const schedule = require('node-schedule');

const rootDir = './frontend';
const nonLocal = process.env.NON_LOCAL === 'true';
const testLogin = process.env.TEST_LOGIN === 'true';
const staticDir = nonLocal ? '/srv/static' : `${rootDir}/static`;

const app = express();

const startDate = `----------------------------\n${new Date().toISOString()}`;
console.log(startDate);
console.error(startDate);

// knex
if (!process.env.db_host || !process.env.db_name
  || !process.env.db_user || !process.env.db_password) {
  console.warn('Warning: specify db_* environment variables!');
}

const knex_config = require('../knexfile.js');
const knex = require('knex')(knex_config[process.env.environment]);

// Prevent migration errors when testing. We migrate in test files.
if (process.env.environment !== 'test') {
  knex.migrate.latest(knex_config[process.env.environment]);
}

// serve static files if developing locally (this route is not reached on servers)
app.use('/static', express.static(staticDir));

const secret = nonLocal ? process.env.COOKIE_SECRET : 'local';

app.use(cookieSession({
  name: 'session',
  secret: secret,
  httpOnly: true,
  secure: nonLocal,
  maxAge: 365 * 24 * 60 * 60 * 1000,
}));

app.use((req, res, next) => {
  res.set('Cache-Control', 'no-cache');
  next();
});
app.set('etag', false);

if (nonLocal) {
  app.set('trust proxy', 'loopback');
}

const userImagesPath = nonLocal ? '/srv/static/images' : `${__dirname}/../frontend/static/images`;

const disableSebacon = process.env.DISABLE_SEBACON === 'true';

const communicationsKey = process.env.COMMUNICATIONS_KEY;
if (!disableSebacon && !communicationsKey) console.warn('You should have COMMUNICATIONS_KEY for avoine in ENV');

const sebaconAuth = process.env.SEBACON_AUTH;
const sebaconCustomer = process.env.SEBACON_CUSTOMER;
const sebaconUser = process.env.SEBACON_USER;
const sebaconPassword = process.env.SEBACON_PASSWORD;
const adminGroup = process.env.ADMIN_GROUP;
if ((!sebaconAuth ||
    !sebaconCustomer ||
    !sebaconUser ||
    !sebaconPassword) && !disableSebacon) {
  console.warn('You should have SEBACON_* parameters for avoine in ENV');
}

const sebacon = require('./sebaconService')({
  customer: sebaconCustomer,
  user: sebaconUser,
  password: sebaconPassword,
  auth: sebaconAuth,
  disable: disableSebacon,
  adminGroup,
  testLogin,
  knex,
});

const enableEmailGlobally = process.env.ENABLE_EMAIL_SENDING === 'true';

const smtpHost = process.env.SMTP_HOST;
const smtpUser = process.env.SMTP_USER;
const smtpPassword = process.env.SMTP_PASSWORD;
const smtpTls = process.env.SMTP_TLS;
const mailFrom = process.env.MAIL_FROM;
const serviceDomain = process.env.SERVICE_DOMAIN;

if (enableEmailGlobally &&
  (!smtpHost || !smtpUser || !smtpPassword || !smtpTls || !mailFrom || !serviceDomain)) {
  console.warn('You should have SMTP_* parameters, MAIL_FROM and SERVICE_DOMAIN in ENV');
}
const smtp =
      { host: smtpHost,
        user: smtpUser,
        password: smtpPassword,
        tls: smtpTls === 'true',
      };

// const restrictToGroup = process.env.RESTRICT_TO_GROUP; // can be empty - used only with Avoine

const util = require('./util')({ knex });
const emails = require('./emails')({ smtp, mailFrom, staticDir, serviceDomain, util, enableEmailGlobally });

const logon = require('./localLogonHandling')({ knex, util, emails });
const profile = require('./profile')({ knex, sebacon, util, userImagesPath, emails });
const ads = require('./ads')({ util, knex, emails, sebacon });
const adNotifications = require('./adNotifications')({ emails, knex, util });
const admin = require('./admin')({ knex, util, sebacon });

// const urlEncoded = bodyParser.urlencoded({ extended: true }); // Used only with Avoine
const jsonParser = bodyParser.json();
const textParser = bodyParser.text();
const fileParser = fileUpload();


if (nonLocal) {
  // schedule every week day at 12 UTC, i.e. 14 or 15 EET
  schedule.scheduleJob({ hour: 12, minute: 0, dayOfWeek: new schedule.Range(1, 5) },
    adNotifications.sendNotifications);
}

// Commented out until Avoine back in use

// only locally, allow logging in with preseeded session
// if (testLogin) {
//   app.get('/kirjaudu/:id', (req, res) => {
//     req.session.id = `00000000-0000-0000-0000-00000000000${req.params.id}`;
//     knex('events')
//       .insert({
//         type: 'login_success',
//         data: { user_id: parseInt(req.params.id, 10), session_id: req.session.id },
//       })
//       .then(() => res.redirect('/'))
//       .catch(() => res.redirect('/'));
//   });
// }

// locally login as 'Tradenomi1' test user, in production redirect to Avoine's authentication
// app.get('/kirjaudu', (req, res) => {
//   if (!testLogin) {
//     let encodedPath = '';
//     if (req.query.path) {
//       encodedPath = encodeURIComponent(`?path=${req.query.path}`);
//     }
//     const encodedParam = encodeURIComponent(req.query.base) + encodedPath;
//     const url = `https://tunnistus.avoine.fi/sso-login/?service=tradenomiitti&return=${encodedParam}`;
//     res.redirect(url);
//   } else {
//     res.redirect('/kirjaudu/1');
//   }
// });
// app.get('/kirjaudu', logon.login);


// Used for local user management
app.post('/kirjaudu', jsonParser, logon.login);
app.get('/uloskirjautuminen', logon.logout);
app.post('/vaihdasalasana', jsonParser, logon.changePassword);
app.post('/rekisteroidy', jsonParser, logon.register);
app.post('/salasanaunohtui', jsonParser, logon.forgotPassword);
app.post('/asetasalasana', jsonParser, logon.initPassword);

app.get('/api/profiilit/oma', profile.getMe);
app.put('/api/profiilit/oma', jsonParser, profile.putMe);
app.put('/api/profiilit/oma/kuva', fileParser, profile.putImage);
app.put('/api/profiilit/oma/kuva/rajattu', fileParser, profile.putCroppedImage);
app.post('/api/profiilit/luo', profile.consentToProfileCreation);
app.get('/api/profiilit', profile.listProfiles);
app.get('/api/profiilit/:id', profile.getProfile);

app.get('/api/tehtavaluokat', (req, res) => {
  const positions = [
    'Asiakaspalvelu',
    'Asiakkuuksien hallinta',
    'Business intelligence',
    'Controller',
    'Copywriter',
    'Edunvalvonta',
    'Esimiestyö',
    'Graafinen suunnittelu',
    'Henkilöstösuunnittelu- ja hallinto',
    'IT-järjestelmäsuunnittelu ja -ylläpito',
    'Kansainväliset suhteet & kauppa',
    'Kiinteistönvälitys',
    'Konsultointi- ja neuvontatehtävät',
    'Laadunhallinta',
    'Logistiikka, huolinta ja rahtaus',
    'Luotonvalvonta ja perintä',
    'Markkinoinnin ja mainonnan yleistehtävät',
    'Myynti',
    'Ohjelmistosuunnittelu ja ohjelmointi',
    'Opetus-, koulutus- ja valmennustehtävät',
    'Osto- ja hankintatehtävät',
    'PR- ja edustustyö',
    'Palkanlaskenta',
    'Palvelumuotoilu',
    'Pankki ja rahoitus',
    'Projektinhallinta',
    'Rekrytointi',
    'Sihteeri- ja assistenttitehtävät',
    'Sijoitustoiminta',
    'Sosiaalinen media',
    'Suunnittelu- ja kehitystehtävät',
    'Taloushallinto ',
    'Tiedottaminen, viestintä ja toimitustyö',
    'Tietohallinto ja tietoturvallisuus',
    'Tilintarkastus',
    'Tulkkaus ja kääntäminen',
    'Tuotannon hallinta ja suunnittelu',
    'Tuotesuunnittelu ja tuotekehitys',
    'Tutkimustehtävät',
    'Vakuutus',
    'Verkkosivustojen ja -palveluiden päivitys ja ylläpito',
    'Verotus',
    'Yrittäjyys',
  ];
  return res.json(positions.sort());
});

app.get('/api/toimialat', (req, res) => {
  const domains = [
    'Arkkitehti- ja insinööripalvelut ja niihin liittyvä konsultointi (esim. insinööri- ja suunnittelutoimistot)',
    'Elintarviketeollisuus',
    'Energia-ala (sähkö-, kaasu- , lämpö- ja vesihuolto)',
    'Graafinen ala',
    'HR & Rekrytointi',
    'Terveys ja Hyvinvointi',
    'ICT-ala (esim. televiestintä, verkon hallinta)',
    'Julkishallinto (sis. virastot, itsenäiset julkisoikeudelliset laitokset esim. Keva, Suomen Pankki, julkisoikeudelliset yhdistykset esim. STEA)',
    'Järjestöt',
    'Kansainväliset organisaatiot ja toimielimet',
    'Kiinteistönvälitys ja -vuokraus',
    'Konsultointi',
    'Koulutus ja opetus',
    'Kunta tai kuntayhtymä',
    'Kustannustoiminta',
    'Kääntäminen ja tulkkaus',
    'Lakipalvelut',
    'Lehtien toimitukset',
    'Liikenneala (esim. Ilma-, tie-, rautatie- ja vesiliikenne)',
    'Markkinointi & viestintä',
    'Matkailu- ja ravintola-ala',
    'Muu palvelutoiminta ',
    'Muut taloushallinnon palvelut',
    'Pankki- ja vakuutusala',
    'Media-ala',
    'Valmistava teollisuus',
    'Seurakunta',
    'Sosiaalipalvelut',
    'Taide, kulttuuri ja museot',
    'IT-ala',
    'Tilintarkastus ja liikkeenjohdon konsultointi',
    'Tukku- ja vähittäiskauppa',
    'Turvallisuusala',
    'Tutkimus ja kehitys',
    'Valtio',
  ];
  return res.json(domains.sort());
});

app.get('/api/lasten_iat', (req, res) => {
  const child_ages = [
    'Ei lapsia',
    '0-6 vuotta',
    '6-12 vuotta',
    '12-18 vuotta',
    'Aikuinen',
  ];
  return res.json(child_ages);
});

app.get('/api/alueet', (req, res, next) => {
  Promise.all([
    knex('users').select(knex.raw("array_agg(distinct data->>'location') as location")).whereNotNull('pw_hash').first(),
    knex('ads').select(knex.raw("array_agg(distinct data->>'location') as location")).first(),
  ])
    .then(([userResult, adsResult]) => {
      const userLocations = userResult.location ? userResult.location : [];
      const adLocations = adsResult.location ? adsResult.location : [];
      const locationSet = new Set(userLocations.concat(adLocations).sort());
      locationSet.delete('');
      locationSet.delete(null);
      return res.json(Array.from(locationSet));
    })
    .catch(next);
});

app.get('/api/osaaminen', (req, res, next) => {
  knex('special_skills').where({}).orderBy('id')
    .then(rows => res.json(rows))
    .catch(next);
});

app.get('/api/koulutus', (req, res, next) => {
  knex('education').where({}).orderBy('id')
    .then(rows => {
      const lists = {
        degree: [],
        specialization: [],
      };
      rows.forEach(o => {
        lists[o.type].push(o);
      });
      return res.json(lists);
    })
    .catch(next);
});
app.post('/api/ilmoitukset', jsonParser, ads.createAd);
app.get('/api/ilmoitukset/:id', ads.getAd);
app.delete('/api/ilmoitukset/:id', ads.deleteAd);
app.get('/api/ilmoitukset', ads.listAds);
app.get('/api/ilmoitukset/tradenomilta/:id', ads.adsForUser);
app.post('/api/ilmoitukset/:id/vastaus', jsonParser, ads.createAnswer);
app.delete('/api/vastaukset/:id', ads.deleteAnswer);


app.get('/api/asetukset', (req, res) =>
  util.userForSession(req)
    .then(dbUser => res.json(util.formatSettings(dbUser.settings)))
    .catch(() => res.json(util.genericError))
);

app.put('/api/asetukset', jsonParser, (req, res) =>
  util.userForSession(req)
    .then(dbUser => {
      const newSettings = Object.assign({}, dbUser.settings, req.body);
      return knex('users').where({ id: dbUser.id }).update('settings', newSettings);
    })
    .then(() => res.sendStatus(200))
);

app.post('/api/kontaktit/:user_id', jsonParser, profile.addContact);
app.get('/api/kontaktit', profile.listContacts);

app.get('/api/raportti', admin.report);

app.post('/api/virhe', textParser, (req, res) => {
  const errorHash = logError(req, req.body);
  res.json(errorHash);
});

app.get('*', (req, res) => {
  res.sendFile('./index.html', { root: staticDir });
});

app.use((err, req, res, next) => {
  const errorHash = logError(req, err);
  res.status(err.status || 500).send(errorHash);
  next();
});

function logError(req, err) {
  const hash = crypto.createHash('sha1');
  hash.update(uuid.v4());
  const errorHash = hash.digest('hex').substr(0, 10);
  console.error(`${errorHash} ${new Date()} ${req.method} ${req.url} ↯`, err);
  return errorHash;
}

module.exports = app.listen(3000, () => {
  console.log('Listening on 3000');
});
