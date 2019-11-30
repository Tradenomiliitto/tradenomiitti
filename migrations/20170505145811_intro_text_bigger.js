
exports.up = function(knex) {
  return knex.schema.alterTable('contacts', function (table) {
    table.string('intro_text', 1000).alter();
  });
};

exports.down = function(knex) {
  return knex.schema.alterTable('contacts', function (table) {
    table.string('intro_text').alter();
  });
};
