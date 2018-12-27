const moment = require('moment');
const groupBy = require('lodash.groupby');

// we implement a shuffle here, because e.g. lodash saves a reference to Math.radom
// at require time, and we want to monkey patch it for reliable tests
// from https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle#The_modern_algorithm
const shuffle = array => {
  /* eslint-disable no-param-reassign */
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
  /* eslint-enable */
};


module.exports = function init(params) {
  const knex = params.knex;
  const util = params.util;
  const profileService = require('./profiles')({ knex, util });

  function getScore(user) {
    return function scoreInner(ad) {
      let score = 0;
      const adDomain = ad.data.domain;
      const adPosition = ad.data.position;
      const adLocation = ad.data.location;

      const domainIncluded = user.domains.map(skill => skill.heading).includes(adDomain);
      const positionIncluded = user.positions.map(skill => skill.heading).includes(adPosition);
      const locationMatches = user.location === adLocation;

      if (domainIncluded) { ++score; }
      if (adDomain && !domainIncluded) { --score; }

      if (positionIncluded) { ++score; }
      if (adPosition && !positionIncluded) { --score; }

      if (locationMatches) { ++score; }
      if (adLocation && !locationMatches) { --score; }

      return score;
    };
  }

  function order(user, ads) {
    const grouped = groupBy(ads, getScore(user));
    const reverseNumericSort = (a, b) => b - a;
    const arrayOfArrays = Object.keys(grouped)
      .sort(reverseNumericSort)
      .map(key => shuffle(grouped[key]));

    return [].concat(...arrayOfArrays);
  }

  function notificationObjects() {
    return usersThatCanReceiveNow()
      .then(userIds => {
        const promises = userIds.map(userId => {
          const adsPromisee = knex('ads')
            .whereNot('user_id', userId)
            .whereRaw('created_at >= ?', [moment().subtract(1, 'months')])
            .whereNotExists(function notExists() {
              this.count('answers.id')
                .from('answers')
                .whereRaw('answers.ad_id = ads.id')
                .havingRaw('count(answers.id) >= 3');
            })
            .whereNotIn('id', function notIn() {
              this.select('ad_id')
                .from('user_ad_notifications')
                .whereRaw('user_ad_notifications.user_id = ?', [userId]);
            });
          const userPromise = util.userById(userId).then(user => util.formatUser(user, true));
          const skillsPromise = profileService.profileSkills(userId);
          return Promise.all([adsPromisee, userPromise, skillsPromise])
            .then(([ads, user, skills]) => {
              util.patchSkillsToUser(user, skills);
              return {
                user,
                ads: order(user, ads).slice(0, 5),
              };
            });
        });
        return Promise.all(promises)
          .then(notifications => notifications
            .filter(notification => notification.ads.length >= 3));
      });
  }

  function usersThatCanReceiveNow() {
    return knex('users').whereNotExists(function notExists() {
      this.select('user_id')
        .from('user_ad_notifications')
        .whereRaw('user_ad_notifications.created_at >= ?'
                  + 'AND users.id = user_ad_notifications.user_id',
        [moment().subtract(7, 'days')]);
    })
      .then(resp => resp.map(x => x.id));
  }

  return {
    usersThatCanReceiveNow,
    notificationObjects,
  };
};
