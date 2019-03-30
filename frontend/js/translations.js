const supportEmail = 'tradenomiitti@tral.fi';

const source = {
  common: {
    supportEmail,
    dateFormat: 'd.M.y',
    title: 'Tradenomiitti',
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
      hint: 'Kokemuksellasi on aina arvoa. Jaa näkemyksesi vastaamalla ilmoitukseen.',
      answerTooltip: 'Osallistu keskusteluun',
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
    isJobAd: 'Tämä on työpaikkailmoitus',
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
    linkStats: {
      text: 'Tilastoja',
    },
    socialButton: {
      facebookUrl: 'https://www.facebook.com/tradenomiliitto',
      twitterUrl: 'https://twitter.com/Tradenomiliitto',
      instagramUrl: 'https://www.instagram.com/tradenomiliitto/',
      linkedinUrl: 'http://www.linkedin.com/groups/Tradenomiliitto-TRAL-ry-2854058/about',
      githubUrl: 'https://github.com/tradenomiliitto/tradenomiitti',
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
    hideJobAds: 'Piilota työpaikkailmoitukset',
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
    profile: 'Profiili',
    login: 'Kirjaudu',
    consentNeeded: {
      heading: 'Tervetuloa Tradenomiittiin!',
      content: 'Tehdäksemme palvelun käytöstä mahdollisimman vaivatonta hyödynnämme Tradenomiliiton olemassa olevia jäsentietoja (nimesi, työhistoriasi). Luomalla profiilin hyväksyt tietojesi käytön Tradenomiitti-palvelussa. Voit muokata tietojasi myöhemmin.',
      iAcceptThe: 'Hyväksyn palvelun ',
      terms: 'käyttöehdot',
      createProfile: 'Luo profiili',
    },
    splashScreen: {
      logoWidth: '400px',
    },
    notImplementedYet: 'Tätä ominaisuutta ei ole vielä toteutettu',
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
  profile: {
    editProfile: {
      heading: 'Muokkaa profiilia',
      hint: 'Tehdäksemme Tradenomiitin käytöstä sinulle mahdollisimman vaivatonta, olemme luoneet sinulle profiilin TRAL:n jäsentietojen perusteella. Viimeistele profiilisi tarkastamalla jäsentietosi, muokkaamalla julkista profiiliasi ja täyttämällä henkilökohtainen käyntikorttisi.',
      nickNameMandatory: 'Kutsumanimi on pakollinen',
      buttonSave: 'Tallenna profiili',
      buttonEdit: 'Muokkaa profiilia',
    },
    membershipInfo: {
      profileUsesMembershipInfo: 'Profiilissa hyödynnetään liiton jäsentietoja. Tarkistathan, että tietosi ovat järjestelmässämme ajan tasalla. ',
      notVisibleAsIs: 'Jäsentiedot eivät näy sellaisenaan muille.',
      buttonUpdateInfo: 'päivitä jäsentiedot',
    },
    publicInfo: {
      heading: 'Julkiset tiedot',
      hint: 'Valitse itsellesi käyttäjänimi (yleisimmin etunimi) ja kuvaava titteli. Esittele itsesi ja osaamisesi muille kuvaavalla tekstillä',
    },
    businessCard: {
      heading: 'Käyntikortti',
      hint: 'Täydennä alle tiedot, jotka haluat lähettää käyntikortin mukana. ',
      visibleForRecipients: 'Tiedot näkyvät vain niille, joille olet lähettänyt kortin',
      notFound: 'Käyntikorttia ei löytynyt',
    },
    businessCardFields: {
      name: 'Koko nimi',
      title: 'Titteli, Työpaikka',
      location: 'Paikkakunta',
      phone: 'Puhelinnumero',
      email: 'Sähköposti',
      linkedIn: 'LinkedIn-linkki',
    },
    competences: {
      editHeading: 'Muokkaa osaamistasi',
      hint: 'Osaamisesi on esitäytetty jäsentietojemme perusteella. Muokkaa ja täydennä tehtäviä ja toimialoja, jotta Tradenomiitti voi palvella sinua paremmin ja jotta muut tradenomit löytäisivät sinut helpommin. ',
      visibleForEveryone: 'Osaaminen näkyy kaikille käyttäjille.',
    },
    ownProfile: {
      notLoggedIn: 'Et ole kirjautunut',
    },
    educations: {
      heading: 'Koulutus',
      institute: 'Oppilaitos',
      degree: 'Tutkintonimike',
      major: 'Koulutus',
      specialization: 'Suuntautuminen / pääaine',
    },
    viewUser: {
      showAllActivity: 'Näytä kaikki aktiivisuus',
      activity: 'Aktiivisuus',
    },
    editProfileBox: {
      hint: 'Onhan profiilisi ajan tasalla? Mielenkiintoinen ja aktiivinen profiili auttaa luomaan kontakteja',
      editProfile: 'Muokkaa profiilia',
    },
    userInfoBox: {
      nickNamePlaceholder: 'Miksi kutsumme sinua?',
      titlePlaceholder: 'Titteli',
      contributionPlaceholder: 'Missä voisin auttaa muita?',
    },
    userDescriptionPlaceholder: 'Kirjoita napakka kuvaus itsestäsi',
    userIdForAdmins: 'Jäsentunniste: ',
    userDomains: {
      heading: 'Toimiala',
      question: 'Valitse toimialat, joista olet kiinnostunut tai sinulla on kokemusta',
      selectDomain: 'Valitse toimiala',
      selectDomainHint: 'Lisää toimiala, josta olet kiinnostunut tai sinulla on osaamista',
    },
    userSkills: {
      heading: 'Osaaminen',
      question: 'Mitä taitoja sinulla on?',
      addSkill: 'Lisää taito',
      selectSkill: 'Valitse taito',
    },
    userPositions: {
      heading: 'Tehtäväluokka',
      question: 'Missä tehtävissä olet toiminut tai haluaisit toimia?',
      selectPosition: 'Valitse tehtäväluokka',
      selectPositionHint: 'Lisää tehtäväluokka, josta olet kiinnostunut tai sinulla on osaamista',
    },
    educationsEditing: {
      hint: 'Lisää koulutus. Valitse omaa koulutustasi parhaiten vastaavat vaihtoehdot. Mikäli oppilaitoksesi on vaihtanut nimeä, valitse nykyisen nimen mukainen oppilaitos. Mikäli valikoista ei löydy oikeaa vaihtoehtoa, voit lisätä sen itse.',
      selectInstitute: 'Valitse oppilaitos',
      selectDegree: 'Valitse tutkintonimike',
      selectMajor: 'Valitse koulutusala / koulutusohjelma',
      selectSpecialization: 'Valitse suuntautuminen / pääaine',
      addEducation: 'Lisää koulutus',
      instituteRequired: 'Oppilaitos on pakollinen tieto',
    },
    membershipRegisterInfo: {
      heading: 'TRAL:n Jäsentiedot',
      nickName: 'Kutsumanimi',
      firstName: 'Etunimi',
      lastName: 'Sukunimi',
      positions: 'Tehtäväluokat',
      domains: 'Toimiala',
      email: 'Sähköposti',
      phone: 'Matkapuhelinnumero',
      location: 'Maakunta',
      missingData: 'Jäsentiedot puuttuvat',
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
  user: {
    contactUser: {
      alreadySent: 'Olet lähettänyt käyntikortin tälle tradenomille.',
      mustContainPhoneOrEmail: 'Käyntikortissasi täytyy olla vähintään puhelinnumero tai sähköpostiosoite, jotta voisit lähettää sen',
      businessCardIsAttached: 'Viestin mukana lähetät käyntikortin',
      editOrContactUserPrompt: 'Kirjoita napakka esittelyteksti',
      contactUserPlaceholder: 'Vähintään 10 merkkiä',
      hint: 'Voisiko {.} auttaa sinua? Jaa käyntikorttisi tästä. ',
      contact: 'Ota yhteyttä',
      submit: 'Lähetä',
    },
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
const list = Object.keys(flatObject).map(key => [key, flatObject[key]]);

export default list;
