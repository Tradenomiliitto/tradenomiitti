
let knex;

function initialize(params) {
  knex = params.knex;
}

function userForSession(req) {
  return knex('sessions')
    .where({ id: req.session.id })
    .then(resp => resp.length === 0 ? Promise.reject('No session found') : resp[0].user_id)
    .then(id => knex('users').where({ id }))
    .then(resp => resp[0]);
}

module.exports = {
  userForSession,
  initialize
};
