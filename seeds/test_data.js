
exports.seed = function(knex, Promise) {
  // Deletes ALL existing entries
  return knex('users').del()
    .then(() => {
      return knex('users').insert({
        id: 1,
        remote_id: -1,
        settings: {},
        data: {}
      });
    }).then(() => {
      return knex('ads').insert({
        id: 1,
        data: {heading: "foo", content: "bar"},
        user_id: 1,
        created_at: new Date(2017, 4, 1)
      });
    }).then(() => {
      return knex('ads').insert({
        id: 2,
        data: {heading: "foo", content: "bar"},
        user_id: 1,
        created_at: new Date(2017, 6, 1)
      });
    }).then(() => {
      return knex('ads').insert({
        id: 3,
        data: {heading: "foo", content: "bar"},
        user_id: 1,
        created_at: new Date(2017, 5, 1)
      });
    })
  ;
};
