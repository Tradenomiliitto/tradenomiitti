
exports.up = function(knex, Promise) {
  return knex.schema.createTable('user_ad_notifications', function(table){
    table.integer('ad_id').references('id').inTable('ads').onDelete('CASCADE');
    table.integer('user_id').references('id').inTable('users').onDelete('CASCADE');
    table.timestamp('created_at').defaultTo(knex.fn.now());
  });
};

exports.down = function(knex, Promise) {
  return knex.schema.dropTable('user_ad_notifications');
};
