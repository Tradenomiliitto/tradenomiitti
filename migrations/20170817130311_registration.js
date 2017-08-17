exports.up = function(knex, Promise) {
  return knex.schema.createTable('registration', function(table) {
    table.integer('user_id').references('id').inTable('users').onDelete('CASCADE');
    table.string('url_token').unique();
    table.timestamp('created_at').defaultTo(knex.fn.now());
  });
};

exports.down = function(knex, Promise) {
  return knex.schema.dropTable('registration');
};
