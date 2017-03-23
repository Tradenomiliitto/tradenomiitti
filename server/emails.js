const emailjs = require('emailjs');

module.exports = function init(params) {
  const server = emailjs.server.connect(params.smtp);

  function send(user) {
    return (
`
<html>
  <head></head>
  <body>
    <h1>Terveiset Tradenomiitista sinulle ${user.name}!</h1>
  </body>
</html>
`
    );
  }

  return {
    send
  };
}
