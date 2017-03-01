
exports.up = function(knex, Promise) {
  return knex.schema.createTable('ads', function (table) {
    table.increments('id');
    table.jsonb('data');
    table.integer('user_id').references('id').inTable('users');
  });
};

exports.down = function(knex, Promise) {
  return knex.schema.dropTable('ads');
};
