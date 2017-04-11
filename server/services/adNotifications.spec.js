/* global describe, beforeEach, afterEach, it */

const chai = require('chai');
const should = chai.should();

const knex_config = require('../../knexfile');
const knex = require('knex')(knex_config['test']);

const util = require('../util')({ knex });
const service = require('./ads')({ knex, util });

describe('Send notifications for ads', function() {

  beforeEach(function(done) {
    knex.migrate.rollback()
      .then(function() {
        knex.migrate.latest()
          .then(function() {
            return knex.seed.run()
              .then(function() {
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


  it('should not send ads to people who have just received a notification', (done) => {
    done();
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
