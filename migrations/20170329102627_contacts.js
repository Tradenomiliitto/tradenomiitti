
exports.up = function(knex) {
  return knex.schema.createTable('contacts', function(table) {
    table.integer('from_user').references('id').inTable('users').onDelete('CASCADE');
    table.integer('to_user').references('id').inTable('users').onDelete('CASCADE');
  })
};

exports.down = function(knex) {
  return knex.schema.dropTable('contacts');
};
