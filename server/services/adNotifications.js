module.exports = function init(params) {
  const knex = params.knex;

  function usersThatCanReceiveNow() {
    return knex('users').where({}).then(resp => resp.map(x => x.id));
  }

  return {
    usersThatCanReceiveNow
  }
}
