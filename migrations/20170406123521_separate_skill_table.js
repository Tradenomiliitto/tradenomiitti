// We don't delete or restore skills to user.data either in ups or downs

exports.up = function(knex) {
  return knex.schema.createTable('skills', function (table) {
    table.integer('user_id').references('id').inTable('users').onDelete('CASCADE');
    table.enum('type', [ 'domain', 'position' ]).index();
    table.integer('level');
    table.string('heading').index();
  }).then(() => knex('users').where({}))
    .then(users => {
      return Promise.all(
        users.map(user => {
          return Promise.all([
            Promise.all(user.data.domains.map(skill => {
              return knex('skills').insert({
                user_id: user.id,
                heading: skill.heading,
                level: skill.skill_level,
                type: 'domain'
              })
            })),
            Promise.all(user.data.positions.map(skill => {
              return knex('skills').insert({
                user_id: user.id,
                heading: skill.heading,
                level: skill.skill_level,
                type: 'position'
              })
            }))
          ])
        })
      )
    })

};

exports.down = function(knex) {
  return knex.schema.dropTable('skills');
};
