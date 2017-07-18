/* global describe, beforeEach, afterEach, it */

const chai = require('chai');
const chaiHttp = require('chai-http');
chai.use(chaiHttp);

const should = chai.should();

const knex_config = require('../../knexfile');
const knex = require('knex')(knex_config['test']);

process.env.environment = 'test';
process.env.TEST_LOGIN = true;
const server = require('../index');

describe('Handle http requests', function() {
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

  var agent = chai.request.agent(server);

  it('should be able to login and add a new ad', () => {
    return agent.get('/kirjaudu')
    .then(() => agent.post('/api/ilmoitukset').send({heading: 'Otsikko', content: 'Sisältö'}))
    .then((res) => knex('ads').where({id: res.body}))    
    .then((ad) => ad[0].data.heading.should.equal('Otsikko'))
    .then(() => knex('ads').select())
    .then((ads) => ads.should.have.length(4));
  });


  it('should be able to login and see login_success event', () => {
    return agent.get('/kirjaudu')
    .then(() => knex('events').select().where({type: 'login_success'}))
    .then((events) => events.should.have.length(1));
  });

  it('should be able to list all ads from API', () => {
    return agent.get('/api/ilmoitukset')
    .then((res) => res.body.should.have.length(3));
  });

  it('should not be able to get a non-existing ad from API', () => {
    return agent.get('/api/ilmoitukset/0')
    .then((res) => res.should.be.an('undefined'))
    .catch((err) => err.should.exist);
  });
});
