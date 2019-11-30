
exports.up = function(knex) {
  return knex.schema.table('users', function (table) {
    table.timestamp('modified_at');
  });
};

exports.down = function(knex) {
  return knex.schema.table('users', function (table){
    table.dropColumn('modified_at');
  })
};
