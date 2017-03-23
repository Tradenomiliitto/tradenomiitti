const emailjs = require('emailjs');
const scssToJson = require('scss-to-json');

const colorsFilepath = __dirname + '/../frontend/stylesheets/colors.scss';
const scssVars = scssToJson(colorsFilepath);

module.exports = function init(params) {
  const server = emailjs.server.connect(params.smtp);

  function send(user, ad) {
    return (
`
<html>
  <head></head>
  <body style="text-align: center; width: 600px; font-family: Arial, sans-serif;">
    <svg
      style="fill: ${scssVars.$pink}; width: 43px; margin-top: 40px;"
      viewBox="0 0 30.982708 27.119791"
    >
      <g
       transform="matrix(0.26458333,0,0,0.26458333,0.10016786,-0.04203889)">
        <path
          d="M 104.1,0 C 97.5,0 92.1,4.9 91.3,11.2 H 72 C 71.2,4.9 65.8,0 59.2,0 52.6,0 47.2,4.9 46.4,11.2 H 25.7 C 24.9,4.9 19.5,0 12.9,0 5.8,0 0,5.8 0,12.9 0,20 5.8,25.8 12.9,25.8 c 6.6,0 12,-4.9 12.8,-11.2 h 20.8 c 0.8,5.8 5.3,10.3 11.1,11.1 v 51.1 c -6.3,0.8 -11.2,6.2 -11.2,12.8 0,7.1 5.8,12.9 12.9,12.9 7.1,0 12.9,-5.8 12.9,-12.9 C 72.2,83 67.3,77.6 61,76.8 V 25.7 c 5.8,-0.8 10.3,-5.3 11.1,-11.1 h 19.3 c 0.8,6.3 6.2,11.2 12.8,11.2 7.1,0 12.9,-5.8 12.9,-12.9 C 117,5.8 111.3,0 104.1,0" />
      </g>
    </svg>
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
    <p style="margin-top: 50px;">Etkö halua enää sähköposteja? Voit muokata sähköpostiasetuksia <a href="https://tradenomiitti.fi/profiili" style="text-decoration: none; color: inherit; font-weight: bold;">Profiili-sivulla</a>.</p>
  </body>
</html>
`
    );
  }

  return {
    send
  };
}
