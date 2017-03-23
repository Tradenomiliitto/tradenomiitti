const emailjs = require('emailjs');
const scssToJson = require('scss-to-json');

const colorsFilepath = __dirname + '/../frontend/stylesheets/colors.scss';
const scssVars = scssToJson(colorsFilepath);

module.exports = function init(params) {

  function send(user, ad) {
    const server = emailjs.server.connect(params.smtp);
    server.send({
      from: params.mailFrom,
      to: 'TBD', // TODO
      text: 'Kirjaudu Tradenomiittiin nähdäksesi vastauksen',
      subject: 'Ilmoitukseesi on vastattu',
      attachment: [
        { data: answerNotificationHtml(user, ad), alternative: true,
          related: [
            { path: `${__dirname}/../frontend/assets/tradenomiitti-tunnus-email.png`, type: 'image/png',
              headers: {"Content-ID":"<logo.png>"},
              name: 'logo.png'
            }
          ]
        },
      ]
    }, (err, message) => {
      console.log(err || message);
    });
  }

  function answerNotificationHtml(user, ad) {
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
      <h2 style="color: ${scssVars.$pink};">${ad.heading}</h2>
      <p>${ad.content}</p>
    </div>
    <p style="margin-top: 50px;">Etkö halua enää sähköposteja? Voit muokata sähköpostiasetuksiasi <a href="https://tradenomiitti.fi/profiili" style="text-decoration: none; color: inherit; font-weight: bold;">Profiili-sivulla</a>.</p>
  </body>
</html>
`
    );
  }

  return {
    send
  };
}
