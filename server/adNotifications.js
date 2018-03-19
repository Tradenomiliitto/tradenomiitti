module.exports = function init(params) {
  const emails = params.emails;
  const knex = params.knex;
  const util = params.util;
  const service = require('./services/adNotifications')({ knex, util });
  const MAXIMUM_RANDOM_DELAY_SECONDS = 180;

  function sendNotifications() {
    return service.notificationObjects()
      .then(notifications => {
        const promises = notifications.map(notification => {
          const user = notification.user;
          const notificationRows = notification.ads.map(ad => ({
            ad_id: ad.id,
            user_id: user.id,
          }));
          // everybody is logged in when reading email
          const formattedAdsPromise =
            Promise.all(notification.ads.map(ad => util.formatAd(ad, true)));
          return knex('user_ad_notifications').insert(notificationRows)
            .then(() => Promise.all([util.userById(user.id), formattedAdsPromise]))
            .then(([dbUser, ads]) => setTimeout(() => emails.sendNotificationForAds(dbUser, ads),
              MAXIMUM_RANDOM_DELAY_SECONDS * Math.random() * 1000));
        });
        return Promise.all(promises);
      })
      .then(() => console.log('Notifications sent'));
  }

  return {
    sendNotifications,
  };
};
