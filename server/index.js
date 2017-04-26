const express = require('express');
const bodyParser = require('body-parser');
const fileUpload = require('express-fileupload');
const uuid = require('uuid');
const crypto = require('crypto');
const request = require('request');
const cookieSession = require('cookie-session');
const schedule = require('node-schedule');

const rootDir = './frontend';
const staticDir = process.env.NON_LOCAL ? '/srv/static' : `${rootDir}/static`;

const app = express();

// knex
const knex_config = require('../knexfile.js');
const knex = require('knex')(knex_config[process.env.environment]);
knex.migrate.latest(knex_config[process.env.environment]);

//serve static files if developing locally (this route is not reached on servers)
app.use('/static', express.static(staticDir));


const secret = process.env.NON_LOCAL ? process.env.COOKIE_SECRET : 'local';

app.use(cookieSession({
  name: 'session',
  secret: secret,
  httpOnly: true,
  secure: process.env.NON_LOCAL,
  maxAge: 365 * 24 * 60 * 60 * 1000
}));

app.use((req, res, next) => {
  res.set('Cache-Control', 'no-cache')
  next();
});
app.set('etag', false);

if (process.env.NON_LOCAL) {
  app.set('trust proxy', 'loopback');
}

const userImagesPath = process.env.NON_LOCAL ? '/srv/static/images' : `${__dirname}/../frontend/static/images`;

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

const smtpHost = process.env.SMTP_HOST;
const smtpUser = process.env.SMTP_USER;
const smtpPassword = process.env.SMTP_PASSWORD;
const smtpTls = process.env.SMTP_TLS;
const mailFrom = process.env.MAIL_FROM;
const serviceDomain = process.env.SERVICE_DOMAIN;
if (!smtpHost || !smtpUser || !smtpPassword || !smtpTls || !mailFrom || !serviceDomain) {
  console.warn("You should have SMTP_* parameters, MAIL_FROM and SERVICE_DOMAIN in ENV");
}
const smtp =
      { host: smtpHost,
        user: smtpUser,
        password: smtpPassword,
        tls: smtpTls === 'true'
      }
const util = require('./util')({ knex });
const emails = require('./emails')({ smtp, mailFrom, staticDir, serviceDomain, util });

const logon = require('./logonHandling')({ communicationsKey, knex, sebacon });
const profile = require('./profile')({ knex, sebacon, util, userImagesPath, emails});
const ads = require('./ads')({ util, knex, emails });
const adNotifications = require('./adNotifications')({ emails, knex, util })

const urlEncoded = bodyParser.urlencoded();
const jsonParser = bodyParser.json();
const textParser = bodyParser.text();
const fileParser = fileUpload();


if (process.env.NON_LOCAL) {
  // schedule every week day at 12 UTC, i.e. 14 or 15 EET
  schedule.scheduleJob({ hour: 12, minute: 0, dayOfWeek: new schedule.Range(1, 5) },
                       adNotifications.sendNotifications);
}

app.post('/kirjaudu', urlEncoded, logon.login );
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
      "Asiakaspalvelu",
      "Asiakkuuksien hallinta",
      "Suhdemarkkinointi ja verkostojen johtaminen",
      "Call Center",
      "Markkinoinnin ja mainonnan yleistehtävät",
      "Markkinoinnin ja mainonnan suunnittelu",
      "Markkinatutkimus",
      "Tiedottaminen, viestintä ja toimitustyö",
      "Copywriter",
      "Verkkosivustojen ja -palveluiden päivitys ja ylläpito",
      "Sosiaalinen media",
      "Graafinen suunnittelu",
      "Tapahtumamarkkinointi ja tapahtumien järjestäminen",
      "PR- ja edustustyö",
      "Palvelumuotoilu",
      "Suunnittelu- ja kehitystehtävät",
      "Tutkimustehtävät",
      "Konsultointi- ja neuvontatehtävät",
      "Henkilöstöhallinnon yleistehtävät",
      "Henkilöstösuunnittelu- ja hallinto",
      "Työnvälitys",
      "Rekrytointi",
      "Esimiestyö",
      "Työnjohto",
      "Yleisjohto",
      "Projektinjohto",
      "Projektinhallinta",
      "Toimistohallinto",
      "Sihteeri- ja assistenttitehtävät",
      "Vaativat assistenttitehtävät",
      "Tuotannon hallinta ja suunnittelu",
      "Tuotehallinta",
      "Tuotesuunnittelu ja tuotekehitys",
      "Myynnin tukitehtävät",
      "Myynti",
      "Myynti (B2B)",
      "IT-järjestelmäsuunnittelu ja -ylläpito",
      "IT-tukihenkilöt ja -käyttöpalvelut",
      "Ohjelmistosuunnittelu ja ohjelmointi",
      "Tietohallinto ja tietoturvallisuus",
      "Logistiikka, huolinta ja rahtaus",
      "Luotonvalvonta ja perintä",
      "Sijoitustoiminta",
      "Pankki ja rahoitus",
      "Vakuutus",
      "Taloushallinnon yleistehtävät",
      "Vaativat taloushallinnon tehtävät",
      "Controller",
      "Palkanlaskenta",
      "Kirjanpito",
      "Business intelligence",
      "Tilintarkastus",
      "Verotus",
      "Osto- ja hankintatehtävät",
      "Myymälänhoito",
      "Myymäläpäälliköt",
      "Kansainvälinen kauppa",
      "Kansainväliset suhteet",
      "Muu kansainvälinen toiminta",
      "Laadunhallinta",
      "Neuvottelutoiminta",
      "Edunvalvonta",
      "Tulkkaus ja kääntäminen",
      "Kirjasto",
      "Kiinteistönhoitotehtävät",
      "Kiinteistönvälitys",
      "Opetus-, koulutus- ja valmennustehtävät",
      "Sosiaaliturvaetuuksien käsittely",
      "Yrittäjyys"
    ];
  return res.json(positions.sort());
});

app.get('/api/toimialat', (req, res) => {
    const domains = [
      "Tukku- ja vähittäiskauppa",
      "Kuljetus ja varastointi",
      "Viestintätoimistot",
      "Mainostoimistot",
      "PR",
      "Lehtien toimitukset",
      "Radio-, elokuva- ja televisiotoiminta & muu media-ala",
      "Graafinen ala",
      "Kääntäminen ja tulkkaus",
      "Kustannustoiminta",
      "ICT-ala (esim. televiestintä, verkon hallinta)",
      "Tietojenkäsittelypalvelut (esim. ohjelmistosuunnittelu, tietopalvelutoiminta)",
      "Muu informaatio- ja viestintäala",
      "Henkilöstöhallinto",
      "Työllistämistoiminta ja työnvälitys",
      "Kiinteistöala (esim. isännöinti, kiinteistönhoito) ja puhtaanapito",
      "Kiinteistönvälitys ja -vuokraus",
      "Arkkitehti- ja insinööripalvelut ja niihin liittyvä konsultointi (esim. insinööri- ja suunnittelutoimistot)",
      "Konsultointi",
      "Lakipalvelut",
      "Rahapeli- ja vedonlyöntipalvelut",
      "Tutkimus ja kehitys",
      "Pankki- ja rahoitustoiminta",
      "Vakuutustoiminta",
      "Julkinen hallinto (esim. verohallinto)",
      "Kunta tai kuntayhtymä",
      "Valtio",
      "Julkisoikeudellinen yhdistys (esim. Suomen Punainen risti, Metsäkeskus tai RAY)",
      "Itsenäinen julkisoikeudellinen laitos (esim. Kela, Keva tai Suomen Pankki)",
      "Seurakunta",
      "Järjestöt",
      "Koulutus ja opetus",
      "Tilintarkastus ja liikkeenjohdon konsultointi",
      "Muut taloushallinnon palvelut",
      "Majoitus ja ravitsemistoiminta",
      "Matkailu",
      "Posti- ja kuriiritoiminta",
      "Kampaamo- ja kauneudenhoitopalvelut",
      "Muu palvelutoiminta (esim. pesulat, hautaustoimistot tai eläinlääkäripalvelut)",
      "Kansainväliset organisaatiot ja toimielimet",
      "Terveyspalvelut",
      "Sosiaalipalvelut",
      "Hyvinvointipalvelut",
      "Urheilu",
      "Virkistys- ja vapaa-ajan palvelut",
      "Taide, kulttuuri ja museot",
      "Musiikki",
      "Elintarviketeollisuus",
      "Kemikaalien, kemiallisten tuotteiden, kumi- ja muovituotteiden, keraamisten ja lasi-, betoni- ja kivituotteiden valmistus",
      "Koksin ja öljytuotteiden valmistus",
      "Kulkuneuvojen valmistus",
      "Lääkeaineiden ja lääkkeiden valmistus",
      "Metallien ja metallituotteiden jalostus",
      "Metallituotteiden, koneiden ja laitteiden valmistus",
      "Paperin, paperi- ja kartonkituotteiden valmistus, puunhankinta, metsänhoito",
      "Sahatavaran ja puutuotteiden valmistus",
      "Tekstiilien, vaatteiden, nahan ja nahkatuotteiden valmistus",
      "Tietokoneiden, elektronisten ja optisten tuotteiden valmistus",
      "Energia-ala (sähkö-, kaasu- , lämpö- ja vesihuolto)",
      "Moottoriajoneuvojen ja moottoripyörien korjaus",
      "Henkilökohtaisten ja kotitaloustavaroiden korjaus",
      "Koneiden ja laitteiden korjaus, huolto ja asennus",
      "Liikenneala (esim. Ilma-, tie-, rautatie- ja vesiliikenne)"
    ];
  return res.json(domains.sort());
});

app.post('/api/ilmoitukset', jsonParser, ads.createAd);
app.get('/api/ilmoitukset/:id', ads.getAd);
app.get('/api/ilmoitukset', ads.listAds);
app.get('/api/ilmoitukset/tradenomilta/:id', ads.adsForUser);
app.post('/api/ilmoitukset/:id/vastaus', jsonParser, ads.createAnswer);


app.get('/api/asetukset', (req, res) => {
  util.userForSession(req).then(dbUser => {
    res.json(util.formatSettings(dbUser.settings));
  });
});

app.put('/api/asetukset', jsonParser, (req, res) => {
  util.userForSession(req).then(dbUser => {
    const newSettings = Object.assign({}, dbUser.settings, req.body);
    return knex('users').where({ id: dbUser.id }).update('settings', newSettings);
  }).then(resp => {
    res.sendStatus(200);
  });
})

app.post('/api/kontaktit/:user_id', jsonParser, profile.addContact);
app.get('/api/kontaktit', profile.listContacts);

app.post('/api/virhe', textParser, (req, res) => {
  const errorHash = logError(req, req.body);
  res.json(errorHash);
});

app.get('*', (req, res) => {
  res.sendFile('./index.html', {root: staticDir})
});

app.use(function(err, req, res, next) {
  const errorHash = logError(req, err);
  res.status(err.status || 500).send(errorHash);
});

function logError(req, err) {
  const hash = crypto.createHash('sha1');
  hash.update(uuid.v4());
  const errorHash = hash.digest('hex').substr(0, 10);
  console.error(`${errorHash} ${req.method} ${req.url} ↯`, err);
  return errorHash;
}

app.listen(3000, () => {
  console.log('Listening on 3000');
});

