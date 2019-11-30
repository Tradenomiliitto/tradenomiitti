
exports.up = function(knex) {
  return knex.schema.table('users', function (table) {
    table.dropColumn('first_name');
    table.dropColumn('description');
    table.jsonb('data');
  });
};

exports.down = function(knex) {
  return knex.schema.table('users', function (table) {
    table.string('first_name');
    table.string('description');
    table.dropColumn('data');
  });
};
