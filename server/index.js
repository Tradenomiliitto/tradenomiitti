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

// knex
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

const communicationsKey = process.env.COMMUNICATIONS_KEY;
if (!communicationsKey) console.warn('You should have COMMUNICATIONS_KEY for avoine in ENV');

const disableSebacon = process.env.DISABLE_SEBACON === 'true';
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
});

const smtpHost = process.env.SMTP_HOST;
const smtpUser = process.env.SMTP_USER;
const smtpPassword = process.env.SMTP_PASSWORD;
const smtpTls = process.env.SMTP_TLS;
const mailFrom = process.env.MAIL_FROM;
const serviceDomain = process.env.SERVICE_DOMAIN;
if (!smtpHost || !smtpUser || !smtpPassword || !smtpTls || !mailFrom || !serviceDomain) {
  console.warn('You should have SMTP_* parameters, MAIL_FROM and SERVICE_DOMAIN in ENV');
}
const smtp =
      { host: smtpHost,
        user: smtpUser,
        password: smtpPassword,
        tls: smtpTls === 'true',
      };

const enableEmailGlobally = process.env.ENABLE_EMAIL_SENDING === 'true';

const restrictToGroup = process.env.RESTRICT_TO_GROUP; // can be empty

const util = require('./util')({ knex });
const emails = require('./emails')({ smtp, mailFrom, staticDir, serviceDomain, util, enableEmailGlobally });

const logon = require('./logonHandling')({ communicationsKey, knex, sebacon, restrictToGroup, testLogin, util });
const profile = require('./profile')({ knex, sebacon, util, userImagesPath, emails });
const ads = require('./ads')({ util, knex, emails, sebacon });
const adNotifications = require('./adNotifications')({ emails, knex, util });
const admin = require('./admin')({ knex, util, sebacon });

const urlEncoded = bodyParser.urlencoded({ extended: true });
const jsonParser = bodyParser.json();
const textParser = bodyParser.text();
const fileParser = fileUpload();


if (nonLocal) {
  // schedule every week day at 12 UTC, i.e. 14 or 15 EET
  schedule.scheduleJob({ hour: 12, minute: 0, dayOfWeek: new schedule.Range(1, 5) },
    adNotifications.sendNotifications);
}

// only locally, allow logging in with preseeded session
if (testLogin) {
  app.get('/kirjaudu/:id', (req, res) => {
    req.session.id = `00000000-0000-0000-0000-00000000000${req.params.id}`;
    knex('events')
      .insert({
        type: 'login_success',
        data: { user_id: parseInt(req.params.id, 10), session_id: req.session.id },
      })
      .then(() => res.redirect('/'))
      .catch(() => res.redirect('/'));
  });
}

// locally login as 'Tradenomi1' test user, in production redirect to Avoine's authentication
app.get('/kirjaudu', (req, res) => {
  if (!testLogin) {
    let encodedPath = '';
    if (req.query.path) {
      encodedPath = encodeURIComponent(`?path=${req.query.path}`);
    }
    const encodedParam = encodeURIComponent(req.query.base) + encodedPath;
    const url = `https://tunnistus.avoine.fi/sso-login/?service=tradenomiitti&return=${encodedParam}`;
    res.redirect(url);
  } else {
    res.redirect('/kirjaudu/1');
  }
});

app.post('/kirjaudu', urlEncoded, logon.login);
app.get('/uloskirjautuminen', logon.logout);

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
    'Suhdemarkkinointi ja verkostojen johtaminen',
    'Call Center',
    'Markkinoinnin ja mainonnan yleistehtävät',
    'Markkinoinnin ja mainonnan suunnittelu',
    'Markkinatutkimus',
    'Tiedottaminen, viestintä ja toimitustyö',
    'Copywriter',
    'Verkkosivustojen ja -palveluiden päivitys ja ylläpito',
    'Sosiaalinen media',
    'Graafinen suunnittelu',
    'Tapahtumamarkkinointi ja tapahtumien järjestäminen',
    'PR- ja edustustyö',
    'Palvelumuotoilu',
    'Suunnittelu- ja kehitystehtävät',
    'Tutkimustehtävät',
    'Konsultointi- ja neuvontatehtävät',
    'Henkilöstöhallinnon yleistehtävät',
    'Henkilöstösuunnittelu- ja hallinto',
    'Työnvälitys',
    'Rekrytointi',
    'Esimiestyö',
    'Työnjohto',
    'Yleisjohto',
    'Projektinjohto',
    'Projektinhallinta',
    'Toimistohallinto',
    'Sihteeri- ja assistenttitehtävät',
    'Vaativat assistenttitehtävät',
    'Tuotannon hallinta ja suunnittelu',
    'Tuotehallinta',
    'Tuotesuunnittelu ja tuotekehitys',
    'Myynnin tukitehtävät',
    'Myynti',
    'Myynti (B2B)',
    'IT-järjestelmäsuunnittelu ja -ylläpito',
    'IT-tukihenkilöt ja -käyttöpalvelut',
    'Ohjelmistosuunnittelu ja ohjelmointi',
    'Tietohallinto ja tietoturvallisuus',
    'Logistiikka, huolinta ja rahtaus',
    'Luotonvalvonta ja perintä',
    'Sijoitustoiminta',
    'Pankki ja rahoitus',
    'Vakuutus',
    'Taloushallinnon yleistehtävät',
    'Vaativat taloushallinnon tehtävät',
    'Controller',
    'Palkanlaskenta',
    'Kirjanpito',
    'Business intelligence',
    'Tilintarkastus',
    'Verotus',
    'Osto- ja hankintatehtävät',
    'Myymälänhoito',
    'Myymäläpäälliköt',
    'Kansainvälinen kauppa',
    'Kansainväliset suhteet',
    'Muu kansainvälinen toiminta',
    'Laadunhallinta',
    'Neuvottelutoiminta',
    'Edunvalvonta',
    'Tulkkaus ja kääntäminen',
    'Kirjasto',
    'Kiinteistönhoitotehtävät',
    'Kiinteistönvälitys',
    'Opetus-, koulutus- ja valmennustehtävät',
    'Sosiaaliturvaetuuksien käsittely',
    'Yrittäjyys',
  ];
  return res.json(positions.sort());
});

app.get('/api/toimialat', (req, res) => {
  const domains = [
    'Tilitoimistot',
    'Turvallisuusala',
    'Tukku- ja vähittäiskauppa',
    'Kuljetus ja varastointi',
    'Viestintätoimistot',
    'Mainostoimistot',
    'PR',
    'Lehtien toimitukset',
    'Radio-, elokuva- ja televisiotoiminta & muu media-ala',
    'Graafinen ala',
    'Kääntäminen ja tulkkaus',
    'Kustannustoiminta',
    'ICT-ala (esim. televiestintä, verkon hallinta)',
    'Tietojenkäsittelypalvelut (esim. ohjelmistosuunnittelu, tietopalvelutoiminta)',
    'Muu informaatio- ja viestintäala',
    'Henkilöstöhallinto',
    'Työllistämistoiminta ja työnvälitys',
    'Kiinteistöala (esim. isännöinti, kiinteistönhoito) ja puhtaanapito',
    'Kiinteistönvälitys ja -vuokraus',
    'Arkkitehti- ja insinööripalvelut ja niihin liittyvä konsultointi (esim. insinööri- ja suunnittelutoimistot)',
    'Konsultointi',
    'Lakipalvelut',
    'Rahapeli- ja vedonlyöntipalvelut',
    'Tutkimus ja kehitys',
    'Pankki- ja rahoitustoiminta',
    'Vakuutustoiminta',
    'Julkinen hallinto (esim. verohallinto)',
    'Kunta tai kuntayhtymä',
    'Valtio',
    'Julkisoikeudellinen yhdistys (esim. Suomen Punainen risti, Metsäkeskus tai RAY)',
    'Itsenäinen julkisoikeudellinen laitos (esim. Kela, Keva tai Suomen Pankki)',
    'Seurakunta',
    'Järjestöt',
    'Koulutus ja opetus',
    'Tilintarkastus ja liikkeenjohdon konsultointi',
    'Muut taloushallinnon palvelut',
    'Majoitus ja ravitsemistoiminta',
    'Matkailu',
    'Posti- ja kuriiritoiminta',
    'Kampaamo- ja kauneudenhoitopalvelut',
    'Muu palvelutoiminta (esim. pesulat, hautaustoimistot tai eläinlääkäripalvelut)',
    'Kansainväliset organisaatiot ja toimielimet',
    'Terveyspalvelut',
    'Sosiaalipalvelut',
    'Hyvinvointipalvelut',
    'Urheilu',
    'Virkistys- ja vapaa-ajan palvelut',
    'Taide, kulttuuri ja museot',
    'Musiikki',
    'Elintarviketeollisuus',
    'Kemikaalien, kemiallisten tuotteiden, kumi- ja muovituotteiden, keraamisten ja lasi-, betoni- ja kivituotteiden valmistus',
    'Koksin ja öljytuotteiden valmistus',
    'Kulkuneuvojen valmistus',
    'Lääkeaineiden ja lääkkeiden valmistus',
    'Metallien ja metallituotteiden jalostus',
    'Metallituotteiden, koneiden ja laitteiden valmistus',
    'Paperin, paperi- ja kartonkituotteiden valmistus, puunhankinta, metsänhoito',
    'Sahatavaran ja puutuotteiden valmistus',
    'Tekstiilien, vaatteiden, nahan ja nahkatuotteiden valmistus',
    'Tietokoneiden, elektronisten ja optisten tuotteiden valmistus',
    'Energia-ala (sähkö-, kaasu- , lämpö- ja vesihuolto)',
    'Moottoriajoneuvojen ja moottoripyörien korjaus',
    'Henkilökohtaisten ja kotitaloustavaroiden korjaus',
    'Koneiden ja laitteiden korjaus, huolto ja asennus',
    'Liikenneala (esim. Ilma-, tie-, rautatie- ja vesiliikenne)',
  ];
  return res.json(domains.sort());
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
        institute: [],
        degree: [],
        major: [],
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


// send user's settings, or default settings
app.get('/api/asetukset', (req, res) =>
  util.userForSession(req)
    .then(dbUser => res.json(util.formatSettings(dbUser.settings)))
        .catch(() => res.json(util.formatSettings({})))
);

app.put('/api/asetukset', jsonParser, (req, res, next) => {
  util.loggedIn(req)
    .then(isLoggedIn => {
      if (isLoggedIn)
        return util.userForSession(req)
          .then(dbUser => {
            const newSettings = Object.assign({}, dbUser.settings, req.body);
            return knex('users').where({ id: dbUser.id }).update('settings', newSettings);
          })
          .then(() => res.sendStatus(200))
          .catch(next)
      else
        return res.sendStatus(200)
    })
});

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
