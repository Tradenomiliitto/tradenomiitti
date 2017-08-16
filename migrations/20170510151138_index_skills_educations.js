exports.up = function(knex, Promise) {
  return knex.schema.createTable('user_special_skills', function (table) {
    table.integer('user_id').references('id').inTable('users').onDelete('CASCADE');
    table.string('heading').index();
  }).then(() => {
    return knex.schema.createTable('user_educations', function (table) {
      table.integer('user_id').references('id').inTable('users').onDelete('CASCADE');
      table.jsonb('data');
    })
  }).then(() => knex('users').where({}))
    .then(users => {
      const userPromises = users.map(user => {
        const skillPromises = user.data.special_skills ? user.data.special_skills.map(skill => {
          return knex('user_special_skills').insert({
            user_id: user.id,
            heading: skill
          })
        }) : [];

        const educationPromises = user.data.education ? user.data.education.map(education => {
          return knex('user_educations').insert({
            user_id: user.id,
            data: education
          });
        }) : [];
        return Promise.all(skillPromises.concat(educationPromises));
      })
      return Promise.all(userPromises);
    }).then(() => {
      return Promise.all([
        knex.schema.raw("CREATE INDEX education_specialization_index ON user_educations((data->>'specialization'));"),
      ]);
    });
};

exports.down = function(knex, Promise) {
  return Promise.all([
    knex.schema.dropTable('user_special_skills'),
    knex.schema.dropTable('user_educations')
  ])
};
