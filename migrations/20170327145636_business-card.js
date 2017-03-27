
exports.up = function(knex, Promise) {
  return knex.schema.table('users', function(table) {
    table.jsonb('business-card');
  });
};

exports.down = function(knex, Promise) {
  return knex.schema.table('users', function(table) {
    table.dropColumn('business-card');
  })
};
