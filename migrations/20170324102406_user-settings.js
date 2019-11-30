
exports.up = function(knex) {
  return knex.schema.table('users', function (table) {
    table.jsonb('settings');
  });
};

exports.down = function(knex) {
  return knex.schema.table('users', function (table) {
    table.dropColumn('settings');
  });
};
