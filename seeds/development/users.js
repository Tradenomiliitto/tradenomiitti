const parse = require('csv-parse/lib/sync');
const fs = require('fs');
const bcrypt = require('bcryptjs');

function formatData(data) {
  const newData = [];
  data.forEach(item => {
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

    newItem.data = JSON.stringify(newItem.data);
    newItem.settings = JSON.stringify(newItem.settings);

    newData.push(newItem);
  });
  return newData;
}

// Update the users table
// Add all new rows based on remote_id
// Update the email of the existing rows
exports.seed = function (knex, Promise) {
  const input = fs.readFileSync('conf/assets/users.csv', 'utf8');
  const data = parse(input, { columns: true });
  const formattedData = formatData(data);
  const query = knex('users').insert(formattedData).toQuery() + ' ON CONFLICT (remote_id) DO UPDATE SET settings = jsonb_set(users.settings, \'{email_address}\', EXCLUDED.settings->\'email_address\')';
  return knex.raw(query);
};
