
exports.up = function(knex) {
  return knex.schema.createTable('ads', function (table) {
    table.increments('id');
    table.jsonb('data');
    table.integer('user_id').references('id').inTable('users');
    table.index('user_id');
  });
};

exports.down = function(knex) {
  return knex.schema.dropTable('ads');
};

