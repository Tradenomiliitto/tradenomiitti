/* global describe, beforeEach, afterEach, it */

const chai = require('chai');
const should = chai.should();

const moment = require('moment');
const MockDate = require('mockdate');

const knex_config = require('../../knexfile');
const knex = require('knex')(knex_config['test']);

const util = require('../util')({ knex });
const service = require('./profiles')({ knex, util });

const aDate = new Date('2018-01-13T11:00:00.000Z');
MockDate.set(aDate);

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
      users.map(user => user.id).should.include(1);
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

  it('should sort by activity by default', (done) => {
    knex('users').insert({id: 3, remote_id: -3, data: {}, settings: {}, modified_at: moment()}).then(() => {
      service.listProfiles(false, undefined, undefined, undefined, undefined, undefined, undefined).then((users) => {
        users.should.have.length(3);
        users[0].id.should.equal(3);
        done();
      })
    })
  })
});
