
exports.up = function(knex, Promise) {
  return knex.schema.table('users', function (table) {
    table.jsonb('settings');
  });
};

exports.down = function(knex, Promise) {
  return knex.schema.table('users', function (table) {
    table.dropColumn('settings');
  });
};
