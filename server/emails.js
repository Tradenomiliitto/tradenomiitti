const emailjs = require('emailjs');
const scssToJson = require('scss-to-json');

const colorsFilepath = __dirname + '/../frontend/stylesheets/colors.scss';
const scssVars = scssToJson(colorsFilepath);

module.exports = function init(params) {

  function sendNotificationForAnswer(dbUser, ad) {

    const attachment = [
        { data: answerNotificationHtml(ad), alternative: true,
          related: [
            { path: `${__dirname}/../frontend/assets/tradenomiitti-tunnus-email.png`, type: 'image/png',
              headers: {"Content-ID":"<logo.png>"},
              name: 'logo.png'
            }
          ]
        },
      ]
    const text = 'Kirjaudu Tradenomiittiin nähdäksesi vastauksen';
    const subject = 'Ilmoitukseesi on vastattu'
    sendEmail(dbUser, text, subject, attachment);
  }

  function sendNotificationForContact(receiver, contactUser) {
    const attachment = [
        { data: contactNotificationHtml(contactUser), alternative: true,
          related: [
            { path: `${__dirname}/../frontend/assets/tradenomiitti-tunnus-email.png`, type: 'image/png',
              headers: {"Content-ID":"<logo.png>"},
              name: 'logo.png'
            },
            { path: `${params.staticDir}/images/${contactUser.data.cropped_picture}`, type: 'image/png',
              headers: {"Content-ID":"<picture.png>"},
              name: 'picture.png'
            }
          ]
        },
      ]
    const text = 'Kirjaudu Tradenomiittiin nähdäksesi kontaktin profiilin'
    const subject = 'Olet saanut uuden kontaktin'

    sendEmail(receiver, text, subject, attachment);
  }

  function sendEmail(receiver, text, subject, attachment) {
    const { email_address, emails_for_answers } = receiver.settings || {};
    if (! (emails_for_answers && email_address && email_address.includes('@'))) {
      return;
    }
    const server = emailjs.server.connect(params.smtp);
    server.send({
      from: params.mailFrom,
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
      <a style="text-transform: uppercase; background-color: ${scssVars.$pink}; padding-left: 45px; padding-right: 45px; padding-top: 25px; padding-bottom: 25px; color: ${scssVars.$white}; text-decoration: none;" href="https://tradenomiitti.fi/ilmoitukset/${ad.id}">Katso vastaus</a>
    </p>
    <h4 style="font-weight: bold; text-transform: uppercase; margin-top: 100px;">Ilmoituksesi</h4>
    <div style="width: 80%; background-color: ${scssVars['$light-grey-background']}; border-color: ${scssVars['$medium-grey']}; border-style: solid; border-width: 1px; padding: 30px; margin-left: auto; margin-right: auto;">
      <h2 style="color: ${scssVars.$pink};">${ad.data.heading}</h2>
      <p>${ad.data.content}</p>
    </div>
    <p style="margin-top: 50px;">Etkö halua enää sähköposteja? Voit muokata sähköpostiasetuksiasi <a href="https://tradenomiitti.fi/asetukset" style="text-decoration: none; color: inherit; font-weight: bold;">Käyttäjätilin asetuksista</a>.</p>
  </body>
</html>
`
    );
  }

  function contactNotificationHtml(user) {
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
      <a style="text-transform: uppercase; background-color: ${scssVars.$pink}; padding-left: 45px; padding-right: 45px; padding-top: 25px; padding-bottom: 25px; color: ${scssVars.$white}; text-decoration: none;" href="https://tradenomiitti.fi/tradenomit/${user.id}">Katso profiili</a>
    </p>
    <p>Tähän tulee saateviesti...</p>
    <div style="padding: 30px; background-color: ${scssVars['$light-grey-background']}; text-align: left;">
      <span style="width: 80px; height: 80px; border-radius: 40px; display: inline-block; overflow: hidden; background-color: ${scssVars.$pink};">
        <img src="cid:picture.png" style="width: 100%;">
        </img>
      </span>
      <span>
        <h2>${user.data.business_card.name}</h2>
        <h3 style="color: ${scssVars.$pink};">${user.data.business_card.title}</h3>
      </span>
      <p style="color: ${scssVars.$pink};">${user.data.business_card.location}</p>
      <hr style="background-color: ${scssVars['$inactive-grey']}; height: 1px; border: 0;"></hr>
      <p style="color: ${scssVars.$pink};">${user.data.business_card.phone}</p>
      <hr style="background-color: ${scssVars['$inactive-grey']}; height: 1px; border: 0;"></hr>
      <p style="color: ${scssVars.$pink};">${user.data.business_card.email}</p>
      <hr style="background-color: ${scssVars['$inactive-grey']}; height: 1px; border: 0;"></hr>
    </div>
    <p style="margin-top: 50px;">Etkö halua enää sähköposteja? Voit muokata sähköpostiasetuksiasi <a href="https://tradenomiitti.fi/asetukset" style="text-decoration: none; color: inherit; font-weight: bold;">Käyttäjätilin asetuksista</a>.</p>
  </body>
</html>
`
    );
  }

  return {
    sendNotificationForAnswer,
    sendNotificationForContact
  };
}