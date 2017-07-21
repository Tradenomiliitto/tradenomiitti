const supportEmail = 'tradenomiitti@tral.fi';

const source = {
  common: {
    supportEmail,
    dateFormat: 'd.M.y',
    readMore: 'lue lisää',
    cancel: 'Peru',
    login: 'Kirjaudu',
    logout: 'Kirjaudu ulos',
    tabs: {
      profile: 'Oma profiili',
      settings: 'Asetukset',
      contacts: 'Käyntikortit',
    },
    selectFilters: {
      domain: 'Valitse toimiala',
      position: 'Valitse tehtäväluokka',
      location: 'Valitse maakunta',
    },
    lengthHint: {
      needsNMoreChars: 'Vielä vähintään {.} merkkiä',
      fitsAtMostNCharsMore: 'Enää korkeintaan {.} merkkiä',
      tooLongByNChars: '{.} merkkiä liian pitkä',
    },
  },
  ad: {
    requestFailed: 'Ilmoituksen haku epäonnistui',
    noAnswersYet: 'Tällä ilmoituksella ei ole vielä yhtään vastausta',
    noAnswersHint: 'Lisää omasi ylhäällä',
    answerCount: {
      0: {
        heading: 'Tähän ilmoitukseen ei ole vastattu kertaakaan',
        hint: 'Kirjaudu sisään ja ole ensimmäinen',
      },
      1: {
        heading: 'Tällä ilmoituksella on yksi vastaus',
        hint: 'Kirjaudu sisään nähdäksesesi sen ja lisää omasi',
      },
      n: {
        heading: 'Tähän ilmoitukseen on vastattu {.} kertaa',
        hint: 'Kirjaudu sisään nähdäksesi vastaukset ja lisää omasi',
      },
    },
    leaveAnswerBox: {
      placeholder: 'Kirjoita napakka vastaus',
      submit: 'Jätä vastaus',
    },
    leaveAnswerPrompt: {
      isAsker: 'Muut käyttäjät voivat vastata ilmoitukseesi tällä sivulla. Näet vastaukset alla kun niitä tulee.',
      hasAnswered: 'Olet vastannut tähän ilmoitukseen. Kiitos kun autoit kanssatradenomiasi!',
      hint: 'Kokemuksellasi on aina arvoa. Jaa näkemyksesi vastaamalla ilmoitukseen.',
      answerTooltip: 'Voit vastata muiden esittämiin kysymyksiin kerran',
      cannotAnswerTooltip: 'Et voi vastata tähän kysymykseen',
      submit: 'Vastaa ilmoitukseen',
    },
  },
  contacts: {
    heading: 'Käyntikortit',
  },
  createAd: {
    headingInputPlaceholder: 'Otsikko',
    adInputPlaceholder: 'Kirjoita ytimekäs ilmoitus',
    filtersHeading: 'Kenen toivot vastaavan?',
    filtersInfo: 'Valitsemalla toimialan tai tehtävän varmistat, että kysymyksesi löytää vastaajansa. Valittu kohderyhmä saa myös ilmoituksesi sähköpostina.',
    submit: 'Julkaise ilmoitus',
    successHeading: 'Lähetys onnistui',
    successAdId: 'Ilmoituksen numero on: ',
    successContinue: 'Paina selaimesi päivitä-nappulaa jatkaaksesi',
    errorHeading: 'Jotain meni pieleen',
    errorContinue: 'Ole hyvä ja lataa sivu uudelleen',
  },
  errors: {
    badUrl: 'BadUrl ',
    timeout: 'Vastauksen saaminen kesti liian kauan, yritä myöhemmin uudelleen',
    networkError: 'Yhteydessä on ongelma, yritä myöhemmin uudelleen',
    badPayload: 'Jotain meni pieleen. Verkosta tuli\n\n{.}\n\nja virhe oli\n\n{.}',
    badStatus: `Haettua sisältöä ei löytynyt. Se on voitu poistaa tai osoitteessa voi olla virhe. Voit ottaa yhteyttä osoitteeseen ${supportEmail} halutessasi. Ota silloin kuvakaappaus sivusta ja lähetä se viestin liitteenä. {.}`,
    codeToUserVisibleMessage: `Jotain meni pieleen. Virheen tunnus on {.}. Meille olisi suuri apu, jos otat kuvakaappauksen koko sivusta ja lähetät sen osoitteeseen ${supportEmail}.`,
    errorResponseFailure: '{.} Järjestelmässä on jotain pahasti pielessä, tutkimme asiaa',
  },
  footer: {
    link1: {
      url: 'http://tral.fi',
      text: 'tral.fi',
    },
    link2: {
      url: 'http://liity.tral.fi/#liity',
      text: 'Liity jäseneksi',
    },
    link3: {
      url: 'mailto:tradenomiitti@tral.fi',
      text: 'Anna palautetta',
    },
  },
  home: {
    introbox: {
      heading: 'Kohtaa tradenomi',
      createProfile: 'Luo oma profiili',
      content: 'Tradenomiitti on tradenomien oma kohtaamispaikka, jossa jäsenet löytävät toisensa yhteisten aiheiden ympäriltä ja hyötyvät toistensa kokemuksista.',
    },
    tradenomiittiInfo: {
      // \xad === &shy;, that is soft hyphen
      heading: 'Ko\xADke\xADmuk\xADsel\xADla\xADsi on aina arvoa',
      paragraph1: 'Tradenomiitti on tradenomien oma kohtaamispaikka, jossa yhdistyvät inspiroivat kohtaamiset ja itsensä kehittäminen. Tradenomiitti tuo tradenomien osaamisen esille - olit sitten opiskelija tai kokenut konkari. Juuri sinulla voi olla vastaus toisen tradenomin kysymykseen, tai ehkä uusi työnantajasi etsii sinua jo?',
      paragraph2: 'Luomalla profiilin pääset alkuun, loput on itsestäsi kiinni.',
    },
    listAds: {
      heading: 'Uusimmat ilmoitukset',
      buttonListAds: 'katso kaikki ilmoitukset',
      buttonCreateAd: 'jätä ilmoitus',
    },
    listUsers: {
      heading: 'Löydä tradenomi',
      buttonListUsers: 'Katso kaikki tradenomit',
      buttonEditProfile: 'Muokkaa omaa profiilia',
      buttonCreateProfile: 'Luo oma profiili',
    },
  },
  listAds: {
    heading: 'Selaa ilmoituksia',
    sort: {
      date: 'Päivämäärä',
      answerCount: 'Vastauksia',
      newestAnswer: 'Uusin vastaus',
    },
  },
  listUsers: {
    heading: 'Selaa tradenomeja',
    sort: {
      activity: 'Aktiivisuus',
      name: 'Nimi',
    },
    filters: {
      institute: 'Valitse oppilaitos',
      specialization: 'Valitse suuntautuminen / pääaine',
      skill: 'Valitse taito',
    },
  },
  loginNeeded: {
    heading: 'Kirjaudu sisään',
    info: 'Tradenomiitti on ainutlaatuinen kohtaamispaikka Tradenomiliiton jäsenille. Sinun tulee kirjautua sisään TRAL-tunnuksillasi, jotta voit luoda profiilin ja toimia Tradenomiitissa.',
    joinHeading: 'Etkö ole vielä TRAL:n jäsen?',
    joinUrl: 'http://tral.fi',
    joinLink: 'Liity jäseneksi',
  },
  main: {
    consentNeeded: {
      heading: 'Tervetuloa Tradenomiittiin!',
      content: 'Tehdäksemme palvelun käytöstä mahdollisimman vaivatonta hyödynnämme Tradenomiliiton olemassa olevia jäsentietoja (nimesi, työhistoriasi). Luomalla profiilin hyväksyt tietojesi käytön Tradenomiitti-palvelussa. Voit muokata tietojasi myöhemmin.',
      accept: 'Hyväksyn palvelun ',
      terms: 'käyttöehdot',
      createProfile: 'Luo profiili',
      profile: 'Profiili',
      login: 'Kirjaudu',
      notImplementedYet: 'Tätä ominaisuutta ei ole vielä toteutettu',
    },
    splashScreen: {
      logoWidth: '400px',
    },
  },
  navigation: {
    sr_open: 'Navigaation avaus',
    logoAlt: 'Tradenomiitti',
    logoWidth: '163px',
    routeNames: {
      user: 'Käyttäjä {.}',
      profile: 'Oma Profiili',
      home: 'Home',
      info: 'Tietoa',
      notFound: 'Ei löytynyt',
      listUsers: 'Tradenomit',
      listAds: 'Ilmoitukset',
      createAd: 'Jätä ilmoitus',
      showAd: 'Ilmoitus {.}',
      loginNeeded: 'Kirjautuminen vaaditaan',
      terms: 'Palvelun käyttöehdot',
      registerDescription: 'Rekisteriseloste',
      settings: 'Asetukset',
      contacts: 'Käyntikortit',
    },
  },
  removal: {
    removeYour: {
      ad: 'Poista oma ilmoituksesi',
      answer: 'Poista oma vastauksesi',
    },
    iWantToRemoveMy: {
      ad: 'Haluan poistaa ilmoitukseni',
      answer: 'Haluan poistaa vastaukseni',
    },
    confirmationText: {
      ad: 'Tämä poistaa ilmoituksen ja kaikki siihen tulleet vastaukset pysyvästi. Oletko varma?',
      answer: 'Tämä poistaa vastauksen pysyvästi. Oletko varma?',
    },
  },
  settings: {
    heading: 'Asetukset',
    emailsHeading: 'Sähköpostit',
    emailsInfo: 'Voit itse valita missä tilanteissa Tradenomiitti lähettää sinulle viestin sähköpostitse. Sähköposti varmistaa sen, että saat tiedon uusista kontakteista, sinua koskevista ilmoituksista ja saamistasi vastauksista.',
    emailAddress: 'Sähköpostiosoite',
    emailsForBusinesscards: 'Ilmoitus uudesta kontaktista/käyntikortista',
    emailsForAnswers: 'Ilmoitus uudesta vastauksesta jättämääsi kysymykseen',
    emailsForNewAds: 'Kootut sinulle suunnatut ilmoitukset (viikottainen)',
    buttonSave: 'Tallenna',
    sending: 'Tallenetaan…',
    success: 'Tallennus onnistui',
    error: 'Tallenuksessa meni jotain pieleen',
  },
  skill: {
    interested: 'Kiinnostunut',
    beginner: 'Vasta-alkaja',
    experienced: 'Osaaja',
    pro: 'Konkari',
  },
};


// transform into flat object with keys like "home.introbox.createProfile"
function flatten(object) {
  const flat = {};
  Object.keys(object).forEach(key => {
    if (typeof object[key] === 'object') {
      const innerFlat = flatten(object[key]);
      Object.keys(innerFlat).forEach(innerKey => {
        flat[`${key}.${innerKey}`] = innerFlat[innerKey];
      });
    } else {
      flat[key] = object[key];
    }
  });
  return flat;
}

const flatObject = flatten(source);

// TODO: remove temporary visibility hack
const matches = (key, str) => key.toLowerCase().indexOf(str) >= 0;
function plaintext(key) {
  return !(matches(key, 'width') || matches(key, 'url'));
}
const list = Object.keys(flatObject).map(key =>
  (plaintext(key)
    ? [key, `«${flatObject[key]}»`]
    : [key, flatObject[key]]
  )
);

export default list;
