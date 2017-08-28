const source = {
  sendNotificationForAnswer: {
    text: 'Kirjaudu MiBitiin nähdäksesi vastauksen',
    subject: 'Ilmoitukseesi on vastattu',
  },
  sendNotificationForContact: {
    text: 'Kirjaudu MiBitiin nähdäksesi kontaktin profiilin',
    subject: 'Olet saanut uuden kontaktin',
  },
  sendNotificationForAds: {
    text: 'Kirjaudu MiBitiin nähdäksesi uusimman sisällön',
    subject: 'Uusia ilmoituksia MiBitissä',
  },
  sendRegistrationEmail: {
    subject: 'Aktivoi MiBiT-tilisi',
    text: 'Hei, tuleva mibiläinen!\r\rAvaamalla alla olevan aktivointilinkin voit asettaa salasanan uudelle MiBiT-tilillesi. Salasanan asettamisen jälkeen tilisi on käytettävissä ja voit kirjautua sisään. Linkki on toiminnassa tietoturvasyistä 24 tuntia ja sitä voi käyttää vain kerran. Sen jälkeen sinun on pyydettävä uusi linkki sähköpostiosoitteellesi. Jos et ole pyytänyt aktivointilinkkiä, voit poistaa tämän viestin',
    signature: 'Ystävällisin terveisin,\rMiBiT-tiimi\r',
  },
  sendRenewPasswordEmail: {
    subject: 'Vaihda MiBiT-tilisi salasana',
    text: 'Hei, mibiläinen!\r\rAvaamalla alla olevan salasananvaihtolinkin voit vaihtaa MiBiT-tilisi salasanan. Linkki on toiminnassa tietoturvasyistä 24 tuntia ja sitä voi käyttää vain kerran. Sen jälkeen sinun on pyydettävä uusi linkki sähköpostiosoitteellesi. Jos et ole pyytänyt salasananvaihtolinkkiä, voit poistaa tämän viestin.',
    signature: 'Ystävällisin terveisin,\rMiBiT-tiimi\r',
  },
  answerNotificationHtml: {
    h1: 'Mibiläinen on vastannut ilmoitukseesi',
    p1: 'Ilmoitus voi tuoda mukanaan uusia arvokkaita kontakteja. Muista lähettää kiinnostaville mibiläisille yksityisviesti ja/tai käyntikortti.',
    a1: 'Katso vastaus',
    h4: 'Ilmoituksesi',
    p2: 'Etkö halua enää sähköposteja? Voit muokata sähköpostiasetuksiasi',
    a2: 'Käyttäjätilin asetuksista',
  },
  contactNotificationHtml: {
    h1: 'Olet saanut uuden kontaktin',
    p1: 'Toinen mibiläinen on antanut sinulle käyntikorttinsa MiBit-palvelussa. Voitte nyt olla yhteydessä ja jakaa osaamistanne vaikka kasvotusten.',
    p2: 'Profiilisivun kautta voit lähettää oman käyntikorttisi.',
    a1: 'Katso profiili',
    detailTitle1: 'Sijainti',
    detailTitle2: 'Puhelinnumero',
    detailTitle3: 'Sähköpostiosoite',
    p3: 'Etkö halua enää sähköposteja? Voit muokata sähköpostiasetuksiasi',
    a2: 'Käyttäjätilin asetuksista',
  },
  singleAdHtml: {
    categoriesText: 'Kaikki mibiläiset',
    a: 'Vastaa ilmoitukseen',
  },
  adNotificationHtml: {
    h1: 'Sinulta odotetaan vastausta',
    p1: 'Toinen mibiläinen on jättänyt ilmoituksen ja toivoo vastausta sinun kaltaiseltasi osaajalta. Auta vertaistasi jakamalla näkemyksesi.',
    p2: 'Etkö halua enää sähköposteja? Voit muokata sähköpostiasetuksiasi',
    a: 'Käyttäjätilin asetuksista',
  },
};

module.exports = source;
