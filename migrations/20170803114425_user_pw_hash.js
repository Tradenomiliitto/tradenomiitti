
exports.up = function(knex, Promise) {
  return knex.schema.table('users', function(table) {
    table.string('pw_hash');
  });
};

exports.down = function(knex, Promise) {
  return knex.schema.table('users', function(table) {
    table.dropColumn('pw_hash');
  });
};
