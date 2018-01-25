const knex_config = require('../knexfile.js');
const knex = require('knex')(knex_config[process.env.environment]);
const readline = require('readline');

readline.emitKeypressEvents(process.stdin);
process.stdin.setRawMode(true);

knex('users').whereNotExists(knex.select('*').from('remote_user_register').whereRaw('users.remote_id = remote_user_register.remote_id'))
  .then(rows => {
    if (rows.length === 0) {
      console.log('No deletable users');
      console.log('Aborting...');
      process.exit();
    }
    console.log('Users below WILL BE DELETED');
    console.log('-----------------');
    for (const row of rows) {
      console.log(`remote_id: ${row.remote_id} email: ${row.settings.email_address} name: ${row.data.name}`);
    }
    console.log('-----------------\n');
    process.stdout.write(`Delete ${rows.length} users (y/n)? `);
    process.stdin.on('keypress', (str, key) => {
      if (key.ctrl && key.name === 'c') {
        process.exit();
      } else if (key.name === 'y') {
        console.log('\nDeleting...');
        Promise.all(rows.map(row => knex('users').del().where('remote_id', row.remote_id)))
          .then(() => {
            console.log('Deleted users');
            process.exit();
            return true;
          })
          .catch(err => {
            console.log(err);
            process.exit();
          });
      } else {
        console.log('\nAborting...');
        process.exit();
      }
    });
    return true;
  })
  .catch(err => {
    console.log(err);
  });
