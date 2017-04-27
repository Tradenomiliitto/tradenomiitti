
exports.up = function(knex, Promise) {
  return knex.schema.table('contacts', function (table) {
    table.string('intro_text');
    table.timestamp('created_at').defaultTo(knex.fn.now());
  });
};

exports.down = function(knex, Promise) {
  return knex.schema.table('contacts', function (table) {
    table.dropColumn('intro_text');
    table.dropColumn('created_at');
  });
};
