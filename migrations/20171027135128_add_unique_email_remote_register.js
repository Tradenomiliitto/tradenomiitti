
exports.up = function(knex, Promise) {
  return knex.schema.table('remote_user_register', function(table) {
    table.string('email_address').unique();
  })
};

exports.down = function(knex, Promise) {
  return knex.schema.table('remote_user_register', function(table) {
    table.dropColumn('email_address');
  });
};
