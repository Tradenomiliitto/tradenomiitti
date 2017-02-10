const express = require('express');

const rootDir = "./frontend"
const app = express();
const knex_config = require('../knexfile.js')
const knex = require('knex')(knex_config.local)

app.get('/api/user/:id', (req, res) => {
  knex('users').where('id', req.params.id)
    .then(function(rows){
      if(rows.length === 0){
         return Promise.reject("Not Found");
      }
      else return rows;
    })
    .then(rows => res.send(rows[0]))
    .catch(e => res.sendStatus(404))
});

app.get('*', (req, res) => {
  res.sendFile('./index.html', {root: rootDir})
});

app.listen(3000, () => {
  console.log('Listening on 3000');
});
