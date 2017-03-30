/* global describe, beforeEach, afterEach, it */

const chai = require('chai');
const should = chai.should();

const knex_config = require('../../knexfile');
const knex = require('knex')(knex_config['test']);

const util = require('../util')({ knex });
const service = require('./profiles')({ knex, util });

describe('Handle users', function() {

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


  it('should list users', (done) => {
    service.listProfiles(false).then((users) => {
      users.map(user => user.id).should.eql([1]);
      done();
    })
  });

  it('should respect limit and offset', (done) => {
    const limit = 0;
    const offset = 0;
    service.listProfiles(false, limit, offset).then((users) => {
      users.should.have.length(0);
      done();
    })
  })
});
