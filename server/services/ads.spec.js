/* global describe, beforeEach, afterEach, it */

const chai = require('chai');
const should = chai.should();

const knex_config = require('../../knexfile');
const knex = require('knex')(knex_config['test']);

const util = require('../util')({ knex });
const service = require('./ads')({ knex, util });

describe('Handle ads', function() {

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


  it('should list ads in order', (done) => {
    service.listAds(false).then((ads) => {
      ads.map(ad => ad.id).should.eql([2, 3, 1]);
      done();
    })
  })
});
