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

    if (item.Salasana) {
      newItem.pw_hash = bcrypt.hashSync(item.Salasana, 8);
    }

    newData.push(newItem);
  });
  return newData;
}

exports.seed = function(knex, Promise) {
  const input = fs.readFileSync('conf/assets/users.csv', 'utf8');
  const data = parse(input, { columns: true });
  const formattedData = formatData(data);
  return knex('users').del()
    .then(() =>
      knex('users').insert(formattedData));
};
