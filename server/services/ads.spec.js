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


  it('should list ads sorted by creation date in descending order', (done) => {
    service.listAds(false).then((ads) => {
      ads.map(ad => ad.id).should.eql([2, 3, 1]);
      done();
    })
  });

  it('should list ads sorted by creation date in ascending order', (done) => {
    service.listAds(false, undefined, undefined, undefined, undefined, undefined, 'created_at_asc').then((ads) => {
      ads.map(ad => ad.id).should.eql([1, 3, 2]);
      done();
    })
  });

  it('should list ads sorted by answer count in descending order', (done) => {
    service.listAds(false, undefined, undefined, undefined, undefined, undefined, 'answers_desc').then((ads) => {
      ads.map(ad => ad.id).should.eql([3, 1, 2]);
      done();
    })
  });

  it('should list ads sorted by answer count in ascending order', (done) => {
    service.listAds(false, undefined, undefined, undefined, undefined, undefined, 'answers_asc').then((ads) => {
      ads.map(ad => ad.id).should.eql([2, 3, 1]);
      done();
    })
  });

  it('should list ads sorted by newest answer date in descending order', (done) => {
    service.listAds(false, undefined, undefined, undefined, undefined, undefined, 'newest_answer_desc').then((ads) => {
      ads.map(ad => ad.id).should.eql([1, 3, 2]);
      done();
    })
  });

  it('should respect limit and offset', (done) => {
    const limit = 1;
    const offset = 2
    service.listAds(false, limit, offset).then((ads) => {
      ads.should.have.length(1);
      ads[0].id.should.equal(1);
      done();
    })
  })
});
