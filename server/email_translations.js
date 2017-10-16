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
    text: 'Tervetuloa MiBiTin käyttäjäksi!\n\nAvaa ensin alla oleva aktivointilinkki ja aseta salasana käyttäjätilillesi. Tämä tulee tietoturvasyistä tehdä 24 tunnin kuluessa aktivointilinkin vastaanottamisesta. Salasanan asettamisen jälkeen MiBiT-tilisi on käytettävissäsi.\n\nVoit pyytää uuden aktivointilinkin sähköpostiosoitteellesi MiBiT-palvelusta.',
    moreInfo: 'Lisätietoa palvelun käytöstä löydät MiBiT-palvelun Tietoa-kohdasta.',
    signature: 'Inspiroivia kohtaamisia toivottaen,\nMothers in Business MiB ry',
  },
  sendRenewPasswordEmail: {
    subject: 'Vaihda MiBiT-tilisi salasana',
    text: 'Hei, mibiläinen!\n\nAvaamalla alla olevan salasananvaihtolinkin voit vaihtaa MiBiT-tilisi salasanan. Linkki on toiminnassa tietoturvasyistä 24 tuntia ja sitä voi käyttää vain kerran. Sen jälkeen sinun on pyydettävä uusi linkki sähköpostiosoitteellesi. Jos et ole pyytänyt salasananvaihtolinkkiä, voit poistaa tämän viestin.',
    signature: 'Ystävällisin terveisin,\nMothers in Business MiB ry\n',
  },
  answerNotificationHtml: {
    h1: 'Mibiläinen on vastannut ilmoitukseesi',
    p1: 'Ilmoitus voi tuoda mukanaan uusia arvokkaita kontakteja. Muista lähettää kiinnostaville mibiläisille käyntikorttisi.',
    a1: 'Katso vastaus',
    h4: 'Ilmoituksesi',
    p2: 'Etkö halua enää sähköposteja? Voit muokata sähköpostiasetuksiasi',
    a2: 'Käyttäjätilin asetuksista',
  },
  contactNotificationHtml: {
    h1: 'Olet saanut uuden kontaktin',
    p1: 'Toinen mibiläinen on antanut sinulle käyntikorttinsa MiBiT-palvelussa ja toivoo yhteydenottoasi. Voit nyt olla häneen yhteydessä sopiaksenne esimerkiksi tapaamisen. Mikäli haluat hänen saavan sinun yhteystietosi palvelussa, voit lähettää profiilisivun kautta voit oman käyntikorttisi.',
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
