
exports.up = function(knex, Promise) {
  return knex.schema.table('remote_user_register', function(table) {
    table.jsonb('member_data');
  })
    .then(() => knex.schema.table('users', function(table) {
      table.jsonb('member_data');
    }));
};

exports.down = function(knex, Promise) {
  return knex.schema.table('remote_user_register', function(table) {
    table.dropColumn('member_data');
  })
    .then(() => knex.schema.table('users', function(table) {
      table.dropColumn('member_data');
    }));
};
