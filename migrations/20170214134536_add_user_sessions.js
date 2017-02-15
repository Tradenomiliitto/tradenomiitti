
exports.up = function(knex, Promise) {
  return Promise.all(
    [
      knex.schema.createTable('sessions', function (table) {
        table.uuid('id').primary();
        table.integer('user_id').references('id').inTable('users');
        table.index('id');
      }),
      knex.schema.table('users', function (table) {
        table.string('remote_id').index();
      })
    ]
  );

};

exports.down = function(knex, Promise) {
  return Promise.all(
    [
      knex.schema.dropTable('sessions'),
      knex.schema.table('users', function (table) {
        table.dropIndex('remote_id');
        table.dropColumn('remote_id');
      })
    ]);
};
