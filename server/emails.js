const emailjs = require('emailjs');
const scssToJson = require('scss-to-json');

const colorsFilepath = __dirname + '/../frontend/stylesheets/colors.scss';
const scssVars = scssToJson(colorsFilepath);

module.exports = function init(params) {

  const staticDir = params.staticDir;
  const smtp = params.smtp;
  const mailFrom = params.mailFrom;
  const serviceDomain = params.serviceDomain;
  const util = params.util;
  const enableEmailGlobally = params.enableEmailGlobally;

  const logo = {
    path: `${__dirname}/../frontend/assets/tradenomiitti-tunnus-email.png`, type: 'image/png',
    headers: {"Content-ID":"<logo.png>"},
    name: 'logo.png'
  };

  function sendNotificationForAnswer(dbUser, ad) {

    const attachment = [
        { data: answerNotificationHtml(ad), alternative: true,
          related: [
            logo
          ]
        },
      ]
    const text = 'Kirjaudu Tradenomiittiin nähdäksesi vastauksen';
    const subject = 'Ilmoitukseesi on vastattu'
    const { email_address, emails_for_answers } = util.formatSettings(dbUser.settings);
    sendEmail(email_address, emails_for_answers, text, subject, attachment);
  }

  function sendNotificationForContact(receiver, contactUser, introductionText) {
    const attachment = [
      { data: contactNotificationHtml(contactUser, introductionText),
        alternative: true,
        related: [
          logo,
          imageAttachment(contactUser.data.cropped_picture, '<picture>')
        ]
      },
    ];
    const text = 'Kirjaudu Tradenomiittiin nähdäksesi kontaktin profiilin'
    const subject = 'Olet saanut uuden kontaktin'

    const { email_address, emails_for_businesscards } = util.formatSettings(receiver.settings);
    sendEmail(email_address, emails_for_businesscards, text, subject, attachment);
  }

  function isUserPic(userPic) {
    return userPic && userPic.length > 0;
  }

  function imageAttachment(userPic, cid) {
    const pic = isUserPic(userPic) ? `images/${userPic}` : 'user.png';
    const imageType = pic.endsWith('.jpg') ? 'image/jpg' : 'image/png';

    return {
      path: `${staticDir}/${pic}`,
      type: imageType,
      headers: {'Content-ID': cid },
      name: pic
    }
  }

  function userPicStyle(userPic) {
    const width = isUserPic(userPic) ? '100%' : '50%';
    const marginTop = isUserPic(userPic) ? '' : 'margin-top: 25%;';
    return `width: ${width}; ${marginTop}`;
  }

  function sendNotificationForAds(user, ads) {
    function makeImage(ad, index) {
      return imageAttachment(ad.created_by.cropped_picture, `<picture${index}>`);
    }
    const adImages = ads.map(makeImage);
    const attachment = [
      { data: adNotificationHtml(ads),
        alternative: true,
        related: [logo].concat(adImages)
      }
    ];
    const text = "Kirjaudu Tradenomiittiin nähdäksesi uusimman sisällön";
    const subject = 'Uusia ilmoituksia Tradenomiitissa';

    const { email_address, emails_for_new_ads } = util.formatSettings(user.settings);
    sendEmail(email_address, emails_for_new_ads, text, subject, attachment);
  }

  function sendEmail(email_address, allow_sending, text, subject, attachment) {
    if (!enableEmailGlobally)
      return;

    if (! (allow_sending && email_address && email_address.includes('@')))
      return;

    const server = emailjs.server.connect(smtp);
    server.send({
      from: mailFrom,
      to: email_address,
      text: text,
      subject: subject,
      attachment: attachment
    }, (err, message) => {
      if(err) {
        console.log(err);
      }
    });
  }


  function answerNotificationHtml(ad) {
    return (
`
<html>
  <head></head>
  <body style="text-align: center; width: 600px; font-family: Arial, sans-serif; margin-left: auto; margin-right: auto;">
    <img style="width: 45px;" src="cid:logo.png" alt="logo" />
    <h1 style="margin-bottom: 50px; color: ${scssVars.$pink}">Tradenomi on vastannut ilmoitukseesi</h1>
    <p>Ilmoitus voi tuoda mukanaan uusia arvokkaita kontakteja. Muista lähettää kiinnostaville tradenomeille yksityisviesti ja/tai käyntikortti.</p>
    <p style="margin-top: 80px;">
      <a style="font-weight: bold; text-transform: uppercase; background-color: ${scssVars.$pink}; padding-left: 45px; padding-right: 45px; padding-top: 25px; padding-bottom: 25px; color: ${scssVars.$white}; text-decoration: none;" href="https://${serviceDomain}/ilmoitukset/${ad.id}">Katso vastaus</a>
    </p>
    <h4 style="font-weight: bold; text-transform: uppercase; margin-top: 100px;">Ilmoituksesi</h4>
    <div style="width: 80%; background-color: ${scssVars['$light-grey-background']}; border-color: ${scssVars['$medium-grey']}; border-style: solid; border-width: 1px; padding: 30px; margin-left: auto; margin-right: auto;">
      <h2 style="color: ${scssVars.$pink};">${ad.data.heading}</h2>
      <p>${ad.data.content}</p>
    </div>
    <p style="margin-top: 50px;">Etkö halua enää sähköposteja? Voit muokata sähköpostiasetuksiasi <a href="https://${serviceDomain}/asetukset" style="text-decoration: none; color: inherit; font-weight: bold;">Käyttäjätilin asetuksista</a>.</p>
  </body>
</html>
`
    );
  }

  function contactNotificationHtml(user, message) {
    return (
`
<html>
  <head></head>
  <body style="text-align: center; width: 600px; font-family: Arial, sans-serif; margin-left: auto; margin-right: auto;">
    <img style="width: 45px;" src="cid:logo.png" alt="logo" />
    <h1 style="margin-bottom: 50px; color: ${scssVars.$pink}">Olet saanut uuden kontaktin</h1>
    <p>Toinen tradenomi on antanut sinulle käyntikorttinsa Tradenomiitti-palvelussa. Voitte nyt olla yhteydessä ja jakaa osaamistanne vaikka kasvotusten.</p>
    <p>Profiili-sivun kautta voit lähettää oman käyntikorttisi</p>
    <p style="margin-top: 80px;">
      <a style="font-weight: bold; text-transform: uppercase; background-color: ${scssVars.$pink}; padding-left: 45px; padding-right: 45px; padding-top: 25px; padding-bottom: 25px; color: ${scssVars.$white}; text-decoration: none;" href="https://${serviceDomain}/tradenomit/${user.id}">Katso profiili</a>
    </p>
    <p style="margin-top: 75px;margin-bottom: 50px;font-weight: bold;">“${message}”</p>
    <div style="padding: 30px; background-color: ${scssVars['$light-grey-background']}; text-align: left;">
      <span style="width: 80px; height: 80px; border-radius: 40px; display: inline-block; overflow: hidden; background-color: ${scssVars.$pink}; float: left; margin-bottom: 25px; margin-right: 10px;">
        <img src="cid:picture" style="${userPicStyle(user.data.cropped_picture)}">
        </img>
      </span>
      <span style="float: left;">
        <h3 style="margin-bottom: 5px;">${user.data.business_card.name}</h2>
        <h5 style="color: ${scssVars.$pink}; margin-top: 0;">${user.data.business_card.title}</h3>
      </span>
      <div style="clear: left;">
        ${makeBusinessCardLine('Sijainti', user.data.business_card.location)}
        ${makeBusinessCardLine('Puhelinnumero', user.data.business_card.phone)}
        ${makeBusinessCardLine('Sähköpostiosoite', user.data.business_card.email)}
      </div>
    </div>
    <p style="margin-top: 50px;">Etkö halua enää sähköposteja? Voit muokata sähköpostiasetuksiasi <a href="https://${serviceDomain}/asetukset" style="text-decoration: none; color: inherit; font-weight: bold;">Käyttäjätilin asetuksista</a>.</p>
  </body>
</html>
`
    );
  }

  function makeBusinessCardLine(detailTitle, detailValue) {
    if (detailValue && detailValue.length > 0) {
        return `
    <p style="margin-top: 10px; margin-bottom: 10px;">
      <span style="font-weight: bold; margin-right: 5px;">${detailTitle}:</span>
      <span style="color: ${scssVars.$pink};">${detailValue}</span>
    </p>
    <hr style="background-color: ${scssVars['$inactive-grey']}; height: 1px; border: 0;"></hr>`
    }
    return '';
  }

  function singleAdHtml(ad, index) {
    const categories = [ ad.domain, ad.position, ad.location ].filter(x => x);
    const categoriesText = categories.length > 0 ? categories.join(', ') : 'Kaikki tradenomit';
    return (
`
<p style="margin-top: 45px; margin-bottom: 45px; font-weight: bold;">${categoriesText}</p>
<div style="padding: 30px; background-color: ${scssVars['$light-grey-background']}; text-align: center;">
  <span style="width: 80px; height: 80px; border-radius: 40px; display: inline-block; overflow: hidden; background-color: ${scssVars.$pink};">
    <img src="cid:picture${index}" style="${userPicStyle(ad.created_by.cropped_picture)}">
    </img>
  </span>
  <h3 style="margin-bottom: 5px;">${ad.created_by.name}</h2>
  <h5 style="color: ${scssVars.$pink}; margin-top: 0;">${ad.created_by.title}</h3>
  <h2 style="color: ${scssVars.$pink}; margin-top: 30px;">${ad.heading}</h2>
  <p>${ad.content}</p>
  <p style="margin-top: 50px; margin-bottom: 70px;">
    <a style="font-weight: bold; text-transform: uppercase; background-color: ${scssVars.$pink}; padding-left: 45px; padding-right: 45px; padding-top: 25px; padding-bottom: 25px; color: ${scssVars.$white}; text-decoration: none;" href="https://${serviceDomain}/ilmoitukset/${ad.id}">Vastaa ilmoitukseen</a>
  </p>
</div>
`
    );
  }

  function adNotificationHtml(ads) {
    return (
`
<html>
  <head></head>
  <body style="text-align: center; width: 600px; font-family: Arial, sans-serif; margin-left: auto; margin-right: auto;">
    <img style="width: 45px;" src="cid:logo.png" alt="logo" />
    <h1 style="margin-bottom: 50px; color: ${scssVars.$pink}; text-transform: uppercase; font-weight: bold;">Sinulta odotetaan vastausta</h1>
    <p style="margin-bottom: 25px;">Toinen tradenomi on jättänyt ilmoituksen ja toivoo vastausta sinun kaltaiseltasi osaajalta. Auta vertaistasi jakamalla näkemyksesi.</p>
    ${ads.map(singleAdHtml).join('')}
    <p style="margin-top: 50px;">Etkö halua enää sähköposteja? Voit muokata sähköpostiasetuksiasi <a href="https://${serviceDomain}/asetukset" style="text-decoration: none; color: inherit; font-weight: bold;">Käyttäjätilin asetuksista</a>.</p>
  </body>
</html>
`
    );
  }


  return {
    sendNotificationForAnswer,
    sendNotificationForContact,
    sendNotificationForAds
  };
}
