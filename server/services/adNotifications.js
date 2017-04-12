const moment = require('moment');

// we implement a shuffle here, because e.g. lodash saves a reference to Math.radom
// at require time, and we want to monkey patch it for reliable tests
// from https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle#The_modern_algorithm
const shuffle = (array) => {
  // from https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math/random#Getting_a_random_integer_between_two_values
  function getRandomInt(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min)) + min;
  }
  for (let i = 0; i < array.length - 2; ++i) {
    const j = getRandomInt(i, array.length);
    const tmp = array[i];
    array[i] = array[j];
    array[j] = tmp;
  }
  return array;
}

module.exports = function init(params) {
  const knex = params.knex;

  function notificationObjects() {
    return usersThatCanReceiveNow()
      .then(userIds => {
        const promises = userIds.map(userId => {
          return knex('ads')
            .whereNot('user_id', userId)
            .whereNotIn('id', function () {
              this.select('ad_id')
                .from('user_ad_notifications')
                .whereRaw('user_ad_notifications.user_id = ?', [ userId ])
            }).then(ads => ({ userId, ads: shuffle(ads).slice(0, 5) }))
        })
        return Promise.all(promises);
      })
  }

  function usersThatCanReceiveNow() {
    return knex('users').whereNotExists(function () {
      this.select('user_id')
        .from('user_ad_notifications')
        .whereRaw('user_ad_notifications.created_at >= ?' +
                  'AND users.id = user_ad_notifications.user_id',
                  [ moment().subtract(7, 'days') ])
    })
      .then(resp => resp.map(x => x.id));
  }

  return {
    usersThatCanReceiveNow,
    notificationObjects
  }
}
