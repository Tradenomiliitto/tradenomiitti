const moment = require('moment');
const groupBy = require('lodash.groupby');

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
  const util = params.util;
  const profileService = require('./profiles')({ knex, util });

  function score(user, skills) {
    util.patchSkillsToUser(user, skills)
    return function(ad) {
      let score = 0;

      if (user.domains.map(skill => skill.heading).includes(ad.domain))
        ++score;
      if (ad.domain && !user.domains.map(skill => skill.heading).includes(ad.domain))
        --score;

      if (user.positions.map(skill => skill.heading).includes(ad.position))
        ++score;
      if (ad.position && !user.positions.map(skill => skill.heading).includes(ad.position))
        --score;

      if (user.location === ad.location)
        ++score;
      if (ad.location && user.location !== ad.location)
        --score;
    }
  }

  function order(user, skills, ads) {
    const grouped = groupBy(ads, score(user, skills));
    const numericSort = (a, b) => a - b;
    const arrayOfArrays = Object.keys(grouped)
          .sort(numericSort)
          .map(key => shuffle(grouped[key]));

    return [].concat.apply([], arrayOfArrays);
  }

  function notificationObjects() {
    return usersThatCanReceiveNow()
      .then(userIds => {
        const promises = userIds.map(userId => {
          const adsPromisee = knex('ads')
            .whereNot('user_id', userId)
            .whereRaw('created_at >= ?', [ moment().subtract(1, 'months') ])
            .whereNotExists(function () {
              this.count('answers.id')
                .from('answers')
                .whereRaw('answers.ad_id = ads.id')
                .havingRaw('count(answers.id) >= 3')
            })
            .whereNotIn('id', function () {
              this.select('ad_id')
                .from('user_ad_notifications')
                .whereRaw('user_ad_notifications.user_id = ?', [ userId ])
            });
          const userPromise = util.userById(userId);
          const skillsPromise = profileService.profileSkills(userId);
          return Promise.all([adsPromisee, userPromise, skillsPromise])
            .then(([ ads, user, skills ]) =>
                  ({ userId: user.id, ads: order(user, skills, ads).slice(0, 5) }))
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
