const express = require('express');
const bodyParser = require('body-parser');
const uuid = require('uuid');
const request = require('request');

const rootDir = "./frontend"
const communicationsKey = process.env.COMMUNICATIONS_KEY;

if (!communicationsKey) {
  console.warn("You should have COMMUNICATIONS_KEY for avoine in ENV");
}

const app = express();

const urlEncoded = bodyParser.urlencoded();

app.post('/login', urlEncoded, (req, res) => {
  const ssoId = req.body.ssoid;
  const validationReq = {
    id: uuid.v4(),
    method: "GetUser",
    params: [
      communicationsKey,
      ssoId
    ],
    jsonrpc: "2.0"
  };
  request.post({
    url: 'https://tunnistus.avoine.fi/mmserver',
    json: validationReq
  }, (err, response, body) => {
    if (err) {
      console.error(err);
      return res.status(500).send('Jotain meni pieleen');
    }

    if (body.error) {
      console.log(body);
      return res.status(400).send('Kirjautuminen epäonnistui');
    }

    return res.send(`Hei ${body.result.name}, olet kirjautunut onnistuneesti`);
  });
  // TODO persistent session
});

app.get('*', (req, res) => {
  res.sendFile('./index.html', {root: rootDir})
});

app.listen(3000, () => {
  console.log('Listening on 3000');
});
