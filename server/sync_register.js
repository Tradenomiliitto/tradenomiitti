const parse = require('csv-parse/lib/sync');
const fs = require('fs');
const knex_config = require('../knexfile.js');
const knex = require('knex')(knex_config[process.env.environment]);

const KEY_PENDING = 'Hakemusvaiheessa olevat jäsenet';
const KEY_FIRSTNAME = 'Etunimi';
const KEY_EMAIL = 'Sähköpostiosoite';
const KEY_DIVISION = 'Paikallisjaosto';
const KEY_ISADMIN = 'Pääkäyttäjät';
const KEY_REMOTEID = 'Jäsennumero';

function isNonEmpty(item, key) {
  return (item[key] !== '');
}

function checkIfKeysMissing(item) {
  const missingKeys = [];
  const neededKeys = [KEY_PENDING, KEY_FIRSTNAME, KEY_EMAIL, KEY_DIVISION,
    KEY_ISADMIN, KEY_REMOTEID];
  neededKeys.forEach(key => {
    if (!Object.prototype.hasOwnProperty.call(item, key)) {
      missingKeys.push(key);
    }
  });
  return missingKeys;
}

function formatData(data) {
  const newData = [];
  data.forEach(item => {
    const missingKeys = checkIfKeysMissing(item);
    if (missingKeys.length) {
      throw new Error(`sync_register: Missing keys: ${missingKeys.join(', ')}`);
    }
    if (isNonEmpty(item, KEY_PENDING)) {
      return;
    }
    const newItem = {
      data: {},
      settings: {},
    };
    if (isNonEmpty(item, KEY_FIRSTNAME)) {
      newItem.data.name = item[KEY_FIRSTNAME];
    }
    if (isNonEmpty(item, KEY_EMAIL)) {
      newItem.settings.email_address = item[KEY_EMAIL];
      newItem.email_address = item[KEY_EMAIL];
    } else {
      // Skip if no email given
      return;
    }
    if (isNonEmpty(item, KEY_DIVISION)) {
      newItem.data.location = item[KEY_DIVISION];
    }

    newItem.settings.isAdmin = item[KEY_ISADMIN] === 'X';
    newItem.remote_id = item[KEY_REMOTEID];

    newItem.data = JSON.stringify(newItem.data);
    newItem.settings = JSON.stringify(newItem.settings);
    newItem.member_data = JSON.stringify(item);

    newData.push(newItem);
  });
  return newData;
}


// Test for duplicates
function validate(data) {
  function compare_id(a, b) {
    if (a.remote_id < b.remote_id) {
      return -1;
    }
    if (a.remote_id > b.remote_id) {
      return 1;
    }
    throw new Error(`sync_register: Duplicate remote_id: ${a.remote_id}`);
  }

  function compare_email(a, b) {
    if (a.email_address < b.email_address) {
      return -1;
    }
    if (a.email_address > b.email_address) {
      return 1;
    }
    throw new Error(`sync_register: Duplicate email: ${a.email_address}`);
  }

  data.sort(compare_id);
  data.sort(compare_email);
}

// Update the users table
// Add all new rows based on remote_id
// Update the email of the existing rows
// TODO: React to errorcode

const input = fs.readFileSync('conf/assets/member_data.csv', 'utf8');
let data = null;
let formattedData = null;
try {
  data = parse(input, { columns: true, relax_column_count: false });
  formattedData = formatData(data);
  validate(formattedData);
} catch (err) {
  console.log(`sync_register: Error: ${err.message}`);
  process.exit(1);
}
// TODO: Should we use a separate column for unique email?
// TODO: Should we do the stuff below more elegantly?
const stats = `Found ${formattedData.length} members and ${data.length - formattedData.length} non-valid/pending`;
knex('remote_user_register').del().then(() => knex('remote_user_register').insert(formattedData))
  .then(() => {
    const query = knex.raw('INSERT INTO "users" ("data", "remote_id", "settings", "member_data") SELECT "data", "remote_id", "settings", "member_data" FROM "remote_user_register" ON CONFLICT (remote_id) DO UPDATE SET member_data = EXCLUDED.member_data, settings = jsonb_set(users.settings, \'{email_address}\', EXCLUDED.settings->\'email_address\'); INSERT INTO "users" ("data", "remote_id", "settings", "member_data") SELECT "data", "remote_id", "settings", "member_data" FROM "remote_user_register" ON CONFLICT (remote_id) DO UPDATE SET settings = jsonb_set(users.settings, \'{isAdmin}\', EXCLUDED.settings->\'isAdmin\')').toQuery();
    return knex.raw(query);
  })
  .then(() => {
    console.log(`sync_register: ${stats}`);
    return knex('users').whereNotExists(knex.select('*').from('remote_user_register').whereRaw('users.remote_id = remote_user_register.remote_id'));
  })
  .then(rows => {
    console.log(`Users to be pruned: ${rows.length}`);
    console.log('sync_register: [Done]');
    return process.exit(0);
  })
  .catch(err => {
    console.log(`sync_register: Error: ${err.message}`);
    return process.exit(1);
  });
