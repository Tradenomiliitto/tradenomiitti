
exports.up = function(knex, Promise) {
  return Promise.all([
    knex.schema.alterTable('users', function(table){
      table.unique('remote_id');
    }),
    knex.schema.alterTable('ads', function(table){
      table.dropForeign('user_id');
      table.foreign('user_id').references('id').inTable('users').onDelete('CASCADE');
    }),
    knex.schema.alterTable('answers', function(table){
      table.dropForeign('ad_id');
      table.foreign('ad_id').references('id').inTable('ads').onDelete('CASCADE');
      table.dropForeign('user_id');
      table.foreign('user_id').references('id').inTable('users').onDelete('CASCADE');
    })
  ]);
};

exports.down = function(knex, Promise) {
  return Promise.all([
    knex.schema.alterTable('users', function(table){
      table.dropUnique('remote_id');
    }),
    knex.schema.alterTable('ads', function(table){
      table.dropForeign('user_id');
      table.foreign('user_id').references('id').inTable('users');
    }),
    knex.schema.alterTable('answers', function(table){
      table.dropForeign('ad_id');
      table.foreign('ad_id').references('id').inTable('ads');
      table.dropForeign('user_id');
      table.foreign('user_id').references('id').inTable('users');
    })
  ]);
};