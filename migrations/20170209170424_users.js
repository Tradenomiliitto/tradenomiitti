
exports.up = function(knex, Promise) {
    return Promise.all(
        knex.schema.createTable('users', function(table){
        table.increments('id');
        table.string('first_name');
        table.string('description');
    })).then(console.log("table created"))
};

exports.down = function(knex, Promise) {
    return Promise.all(
        knex.schema.dropTable('users')
    ).then(console.log("table dropped"))
};
