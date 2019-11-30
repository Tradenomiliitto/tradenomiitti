
exports.up = function(knex) {
  return knex.schema.createTable('users', function(table){
    table.increments('id');
    table.string('first_name');
    table.string('description');
  });
};

exports.down = function(knex) {
  return knex.schema.dropTable('users');
};
