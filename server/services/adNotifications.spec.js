/* global describe, beforeEach, afterEach, it */

const chai = require('chai');
const should = chai.should();

const MockDate = require('mockdate');

const knex_config = require('../../knexfile');
const knex = require('knex')(knex_config['test']);

const util = require('../util')({ knex });
const service = require('./adNotifications')({ knex });

describe('Send notifications for ads', function() {

  beforeEach(function(done) {
    knex.migrate.rollback()
      .then(function() {
        knex.migrate.latest()
          .then(function() {
            return knex.seed.run()
              .then(function() {
                MockDate.reset();
                done();
              });
          });
      });
  });

  afterEach(function(done) {
    knex.migrate.rollback()
      .then(function() {
        done();
      });
  });

  const aDate = new Date('2017-01-13T11:00:00.000Z');
  const aDayLater = new Date('2017-01-14T11:00:00.000Z');
  const twoWeeksLater = new Date('2017-01-27T11:00:00.000Z');


  it('should not send ads to people who have just received a notification', (done) => {
    MockDate.set(aDate);
    knex('user_ad_notifications').insert({
      user_id: 1,
      ad_id: 1
    }).then(() => {
      MockDate.set(aDayLater);
      return service.usersThatCanReceiveNow();
    }).then(users => {
      users.should.include(1);
      done();
    })
  });

  it('should send ads to people who have not recently received a notification', (done) => {
    MockDate.set(aDate);
    knex('user_ad_notifications').insert({
      user_id: 1,
      ad_id: 1
    }).then(() => {
      MockDate.set(twoWeeksLater);
      return service.usersThatCanReceiveNow();
    }).then(users => {
      users.should.not.include(1);
      done();
    })
  });

  it('should not send ads a person has received a notification about', (done) => {
    done();
  });

  it('should send between 3 and 5 ads per notification', (done) => {
    done();
  });

  it('should not send an ad that already has at least 3 answers', (done) => {
    done();
  });

  it('should not send an ad that is more than a month old', (done) => {
    done();
  });

  it('should rather send an ad with a fitting category than any old ad', (done) => {
    done();
  });

  it('should send any old ad if no categories fit', (done) => {
    done();
  });
});
