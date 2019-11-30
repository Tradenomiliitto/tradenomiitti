
exports.up = function(knex) {
  return knex.schema.table('contacts', function(table) {
    table.increments('id');
  });
};

exports.down = function(knex) {
  return knex.schema.table('contacts', function(table) {
    table.dropColumn('id');
  });
};
