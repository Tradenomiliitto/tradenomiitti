
exports.up = function(knex, Promise) {
  return knex.schema.table('users', function (table) {
    table.timestamp('modified_at');
  });
};

exports.down = function(knex, Promise) {
  return knex.schema.table('users', function (table){
    table.dropColumn('modified_at');
  })
};
