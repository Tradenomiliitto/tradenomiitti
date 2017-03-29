/* global describe, beforeEach, afterEach, it */
const knex_config = require('../../knexfile');
const knex = require('knex')(knex_config['test']);

const chai = require('chai');
const should = chai.should();

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
    done();
  })
});
