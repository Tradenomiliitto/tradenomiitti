module.exports = function init(params) {
  const emails = params.emails;
  const knex = params.knex;
  const util = params.util;
  const service = require('./services/adNotifications')({ knex, util });

  function testSending(req, res, next) {
    service.notificationObjects()
      .then(notifications => {
        const promises = notifications.map(notification => {
          const user = notification.user;
          const notificationRows = notification.ads.map(ad => ({
            ad_id: ad.id,
            user_id: user.id
          }))
          return knex('user_ad_notifications').insert(notificationRows)
            .then(() => notifications)
        });
        return Promise.all(promises);
      })
      .then(objects => res.json(objects))
  }

  return {
    testSending
  };
}
