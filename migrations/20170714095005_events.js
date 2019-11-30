
exports.up = function(knex) {
  return knex.schema.createTable('events', function(table ) {
    table.string('type');
    table.timestamp('time_stamp').defaultTo(knex.fn.now());
    table.jsonb('data');
  });
};

exports.down = function(knex) {
    return knex.schema.dropTable('events');
};
