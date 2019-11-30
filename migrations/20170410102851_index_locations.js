
exports.up = function(knex) {
  return knex.schema.raw("CREATE INDEX location_index ON users((data->>'location'));");
};

exports.down = function(knex) {
  return knex.schema.table('users', function (table) {
    table.dropIndex(null, 'location_index');
  });
};
