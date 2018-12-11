/* global describe, beforeEach, afterEach, it */
const chai = require('chai');

const should = chai.should();

const moment = require('moment');
const MockDate = require('mockdate');
const seedrandom = require('seedrandom');

const knex_config = require('../../knexfile');
const knex = require('knex')(knex_config.test);

const util = require('../util')({ knex });
const service = require('./adNotifications')({ knex, util });

const userId = 2;
const otherUserId = 1;

describe('Send notifications for ads', () => {
  beforeEach(done => {
    knex.migrate.rollback()
      .then(() => knex.migrate.latest())
      .then(() => knex.seed.run())
      .then(() => done())
      .catch(done);
  });

  afterEach(done => {
    knex.migrate.rollback()
      .then(() => done())
      .catch(done);
  });

  const aDate = new Date('2017-01-13T11:00:00.000Z');
  const aDayLater = new Date('2017-01-14T11:00:00.000Z');
  const twoWeeksLater = new Date('2017-01-27T11:00:00.000Z');


  it('should not send ads to people who have just received a notification', () => {
    MockDate.set(aDate);
    return knex('user_ad_notifications').insert({
      user_id: userId,
      ad_id: 1,
      created_at: new Date(),
    }).then(() => {
      MockDate.set(aDayLater);
      return service.usersThatCanReceiveNow();
    }).then(users => users.should.not.include(userId));
  });

  it('should send ads to people who have not recently received a notification', () => {
    MockDate.set(aDate);
    return knex('user_ad_notifications').insert({
      user_id: userId,
      ad_id: 1,
      created_at: new Date(),
    }).then(() => {
      MockDate.set(twoWeeksLater);
      return service.usersThatCanReceiveNow();
    }).then(users => users.should.include(userId));
  });

  it('should send ads to people who have never received a notification', () => service.usersThatCanReceiveNow()
    .then(users => users.should.include(userId)));

  it('should not send ads a person has received a notification about', () => {
    MockDate.set(aDate);
    const anAd = {
      data: { heading: 'foo', content: 'bar' },
      user_id: otherUserId,
      created_at: moment(),
    };
    return knex('ads').insert(anAd)
      .then(() => knex('user_ad_notifications').insert({
        user_id: userId,
        ad_id: 1,
        created_at: new Date(),
      }))
      .then(() => {
        MockDate.set(twoWeeksLater);
        return service.notificationObjects();
      })
      .then(notifications => notifications
        .find(notif => notif.user.id === userId)
        .ads
        .map(ad => ad.id)
        .should.not.include(1));
  });

  it('should send at most 5 ads per notification', () => {
    MockDate.set(aDate);
    const anAd = {
      data: { heading: 'foo', content: 'bar' },
      user_id: otherUserId,
      created_at: new Date(),
    };
    return Promise.all([
      knex('ads').insert(anAd),
      knex('ads').insert(anAd),
      knex('ads').insert(anAd),
      knex('ads').insert(anAd),
      knex('ads').insert(anAd),
      knex('ads').insert(anAd),
      knex('ads').insert(anAd),
    ])
      .then(() => {
        MockDate.set(aDayLater);
        return service.notificationObjects();
      })
      .then(notifications => notifications
        .find(notif => notif.user.id === userId)
        .ads
        .should.have.length(5));
  });

  it('should send at least 3 ads per notification', () => {
    MockDate.set(aDate);
    return service.notificationObjects()
      .then(notifications => {
        notifications
          .find(notif => notif.user.id === userId)
          .ads
          .should.have.length(3);

        return should.not.exist(notifications.find(notif => notif.user.id === otherUserId));
      });
  });

  it('should send randomly from the available ads', () => {
    MockDate.set(aDate);
    const anAd = {
      data: { heading: 'foo', content: 'bar' },
      user_id: otherUserId,
      created_at: new Date(),
    };
    return Promise.all([
      knex('ads').insert(anAd),
      knex('ads').insert(anAd),
      knex('ads').insert(anAd),
      knex('ads').insert(anAd),
      knex('ads').insert(anAd),
      knex('ads').insert(anAd),
      knex('ads').insert(anAd),
    ]).then(() => {
      MockDate.set(aDayLater);
      // these two seeds produce different orderings
      seedrandom('first', { global: true });
      return service.notificationObjects();
    }).then(notifications => {
      seedrandom('second', { global: true });
      return Promise.all([
        notifications,
        service.notificationObjects(),
      ]);
    }).then(([notifications1, notifications2]) => notifications1.should.not.eql(notifications2));
  });

  it('should not send ads of the user in question', () => {
    MockDate.set(aDate);
    const forcedAdId = 42;
    const anAd = {
      id: forcedAdId,
      data: { heading: 'foo', content: 'bar' },
      user_id: userId,
      created_at: new Date(),
    };
    return knex('ads').insert(anAd)
      .then(() => service.notificationObjects())
      .then(notifications => {
        const adIds = notifications
          .find(notif => notif.user.id === userId)
          .ads
          .map(ad => ad.id);

        adIds.should.not.include(forcedAdId);
        return adIds.should.have.length(3);
      });
  });

  it('should not send an ad that already has at least 3 answers', () => {
    MockDate.set(aDate);
    const anAnswer = {
      user_id: otherUserId,
      ad_id: 1,
      data: { content: 'foo' },
    };
    const anAd = {
      data: { heading: 'foo', content: 'bar' },
      user_id: otherUserId,
      created_at: moment(),
    };
    return Promise.all([
      knex('ads').insert(anAd),
      knex('answers').insert(anAnswer),
      knex('answers').insert(anAnswer),
      knex('answers').insert(anAnswer),
    ]).then(() => {
      MockDate.set(aDayLater);
      return service.notificationObjects();
    }).then(notifications => {
      const adIds = notifications
        .find(notif => notif.user.id === userId)
        .ads
        .map(ad => ad.id);
      adIds.should.not.include(1);
      return adIds.should.have.length(3);
    });
  });

  it('should not send an ad that is more than a month old', () => {
    MockDate.set(aDate);
    const forcedAdId = 42;
    const anAd = {
      id: forcedAdId,
      data: { heading: 'foo', content: 'bar' },
      user_id: otherUserId,
      created_at: moment().subtract(1, 'months').subtract(2, 'days'),
    };
    return knex('ads').insert(anAd)
      .then(() => service.notificationObjects())
      .then(notifications => {
        const adIds = notifications
          .find(notif => notif.user.id === userId)
          .ads
          .map(ad => ad.id);

        adIds.should.not.include(forcedAdId);
        return adIds.should.have.length(3);
      });
  });

  it('should rather send an ad with a fitting category than any old ad', () => {
    MockDate.set(aDate);
    const forcedAdId = 42;
    const anAd = {
      id: forcedAdId,
      data: { heading: 'foo', content: 'bar', location: 'foobar' },
      user_id: otherUserId,
      created_at: moment(),
    };
    seedrandom('whatever', { global: true });
    return Promise.all([
      knex('users').where('id', userId).update('data', { location: 'foobar' }),
      knex('ads').insert(anAd),
    ]).then(() => service.notificationObjects())
      .then(notifications => {
        const adIds = notifications
          .find(notif => notif.user.id === userId)
          .ads
          .map(ad => ad.id);

        return adIds[0].should.equal(forcedAdId);
      });
  });

  it('should send any old ad if categories in questions are wrong', () => {
    MockDate.set(aDate);
    const forcedAdId = 42;
    const anAd = {
      id: forcedAdId,
      data: { heading: 'foo', content: 'bar', location: 'no-foobar' },
      user_id: otherUserId,
      created_at: moment(),
    };
    seedrandom('whatever', { global: true });
    return Promise.all([
      knex('users').where('id', userId).update('data', { location: 'foobar' }),
      knex('ads').insert(anAd),
    ]).then(() => service.notificationObjects())
      .then(notifications => {
        const adIds = notifications
          .find(notif => notif.user.id === userId)
          .ads
          .map(ad => ad.id);

        adIds[0].should.not.equal(forcedAdId);
        return adIds[3].should.equal(forcedAdId);
      });
  });
});
