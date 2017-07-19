const supportEmail = 'tradenomiitti@tral.fi';

const source = {
  common: {
    supportEmail,
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
  main: {
    consentNeeded: {
      heading: 'Tervetuloa Tradenomiittiin!',
      content: 'Tehdäksemme palvelun käytöstä mahdollisimman vaivatonta hyödynnämme Tradenomiliiton olemassa olevia jäsentietoja (nimesi, työhistoriasi). Luomalla profiilin hyväksyt tietojesi käytön Tradenomiitti-palvelussa. Voit muokata tietojasi myöhemmin.',
      accept: 'Hyväksyn palvelun ',
      terms: 'käyttöehdot',
      createProfile: 'Luo profiili',
    },
    splashScreen: {
      logoWidth: '400px',
    },
  },
  navigation: {
    sr_open: 'Navigaation avaus',
    logoAlt: 'Tradenomiitti',
    logoWidth: '163px',
  },
  home: {
    introbox: {
      heading: 'Kohtaa tradenomi',
      createProfile: 'Luo oma profiili',
      content: 'Tradenomiitti on tradenomien oma kohtaamispaikka, jossa jäsenet löytävät toisensa yhteisten aiheiden ympäriltä ja hyötyvät toistensa kokemuksista.',
    },
    listAds: {
      heading: 'Uusimmat ilmoitukset',
      buttonListAds: 'katso kaikki ilmoitukset',
      buttonCreateAd: 'jätä ilmoitus',
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

// TODO: remove temporary visibility hack
const list = Object.keys(flatObject).map(key =>
  ((key.indexOf('Width') >= 0)
    ? [key, flatObject[key]]
    : [key, `«${flatObject[key]}»`]
  )
);

export default list;
