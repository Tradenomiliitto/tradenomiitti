
exports.up = function(knex, Promise) {
  return Promise.all([
    knex.schema.table('ads', function (table) {
      table.timestamp('created_at').defaultTo(knex.fn.now());
    }),
    knex.schema.createTable('answers', function (table) {
      table.increments('id');
      table.jsonb('data');
      table.integer('user_id').references('id').inTable('users');
      table.integer('ad_id').references('id').inTable('ads');
    })
  ])
};

exports.down = function(knex, Promise) {
  return Promise.all([
    knex.schema.table('ads', function (table){ 
      table.dropColumn('created_at');
    }),
    knex.schema.dropTable('answers')
    ])
};
