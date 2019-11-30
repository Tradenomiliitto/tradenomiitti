
exports.up = function(knex) {
  return Promise.all([
    knex.schema.raw("CREATE INDEX ad_domain_index ON ads((data->>'domain'));"),
    knex.schema.raw("CREATE INDEX ad_position_index ON ads((data->>'position'));"),
    knex.schema.raw("CREATE INDEX ad_location_index ON ads((data->>'location'));")
  ]);
};

exports.down = function(knex) {
  return knex.schema.table('ads', function (table) {
    table.dropIndex(null, 'ad_domain_index');
    table.dropIndex(null, 'ad_position_index');
    table.dropIndex(null, 'ad_location_index');
  });
};
