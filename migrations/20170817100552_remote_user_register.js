exports.up = function(knex, Promise) {
  return knex.schema.createTable('remote_user_register', function(table){
    table.jsonb('data');
    table.string('remote_id').index().unique();
    table.jsonb('settings');
  });
};

exports.down = function(knex, Promise) {
  return knex.schema.dropTable('remote_user_register');
};
