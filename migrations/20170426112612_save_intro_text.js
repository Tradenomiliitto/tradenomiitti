
exports.up = function(knex, Promise) {
  return knex.schema.table('contacts', function (table) {
    table.string('intro_text');
  });
};

exports.down = function(knex, Promise) {
  return knex.schema.table('contacts', function (table) {
    table.dropColumn('intro_text');
  });
};
