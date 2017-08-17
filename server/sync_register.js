const parse = require('csv-parse/lib/sync');
const fs = require('fs');
const bcrypt = require('bcryptjs');
const knex_config = require('../knexfile.js');
const knex = require('knex')(knex_config[process.env.environment]);

function formatData(data) {
  const newData = [];
  data.forEach(item => {
    if (item["Hakemusvaiheessa olevat jäsenet"])
      return;
    const newItem = {
      data: {},
      settings: {},
    };
    if (item.Etunimi) {
      newItem.data.name = item.Etunimi;
    }
    if (item['Sähköpostiosoite']) {
      newItem.settings.email_address = item['Sähköpostiosoite'];
    }
    if (item.Paikallisjaosto) {
      newItem.data.location = item.Paikallisjaosto;
    }

    newItem.settings.isAdmin = item['Pääkäyttäjät'] === 'X';
    newItem.remote_id = item['Jäsennumero'];

    //newItem.pw_hash = bcrypt.hashSync('mibit');
    newItem.data = JSON.stringify(newItem.data);
    newItem.settings = JSON.stringify(newItem.settings);

    newData.push(newItem);
  });
  return newData;
}

// Update the users table
// Add all new rows based on remote_id
// Update the email of the existing rows
const input = fs.readFileSync('conf/assets/users.csv', 'utf8');
const data = parse(input, { columns: true });
const formattedData = formatData(data);
console.log("Delete old stuff...");
knex('remote_user_register').del().then(() => {
  console.log("Import csv...");
  return knex('remote_user_register').insert(formattedData)
}).then(() => {
  console.log("Sync with users...");
  const query = knex.raw('INSERT INTO "users" ("data", "remote_id", "settings") SELECT * FROM "remote_user_register" ON CONFLICT (remote_id) DO UPDATE SET settings = jsonb_set(users.settings, \'{email_address}\', EXCLUDED.settings->\'email_address\')').toQuery();
  return knex.raw(query);
}).then(() => {
  console.log("Done");
  return process.exit();
}).catch(error => {
  console.log(error);
  return process.exit();
});
// const input = fs.readFileSync('conf/assets/users.csv', 'utf8');
// const data = parse(input, { columns: true });
// const formattedData = formatData(data);
// const query = knex('users').insert(formattedData).toQuery() + ' ON CONFLICT (remote_id) DO UPDATE SET settings = jsonb_set(users.settings, \'{email_address}\', EXCLUDED.settings->\'email_address\')';
// console.log("Start register sync...");
// knex.raw(query)
//   .then(() => {
//     console.log("Done");
//     return process.exit();
//   }
// ).catch(error => {
//   console.log(error);
//   return process.exit();
// });
