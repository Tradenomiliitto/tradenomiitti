const moment = require('moment');

module.exports = function init(params) {
  const knex = params.knex;

  function notificationObjects() {
    return usersThatCanReceiveNow()
      .then(userIds => {
        const promises = userIds.map(userId => {
          return knex('ads').whereNotIn('id', function () {
            this.select('ad_id')
              .from('user_ad_notifications')
              .whereRaw('user_ad_notifications.user_id = ?', [ userId ])
          }).then(ads => ({ userId, ads: ads.slice(0, 5) }))
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
