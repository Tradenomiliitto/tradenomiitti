const express = require('express');

const app = express();
app.get('/', (req, res) => {
  res.send('Tervetuloa Tradenomiittiin');
});

app.listen(3000, () => {
  console.log('Listening on 3000');
});
