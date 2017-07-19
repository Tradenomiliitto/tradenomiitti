/* global describe, beforeEach, afterEach, it */

const chai = require('chai');
const chaiHttp = require('chai-http');

chai.use(chaiHttp);
const expect = chai.expect;

const knex_config = require('../../knexfile');
const knex = require('knex')(knex_config.test);

process.env.environment = 'test';
process.env.TEST_LOGIN = true;
const server = require('../index');

describe('Handle API requests', () => {
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

  it('should be able to login, logout and see login_success and logout_success events', () => {
    const agent = chai.request.agent(server);
    return agent.get('/kirjaudu')
      .then(() => knex('events').select().where({ type: 'login_success' }))
      .then(events => events.should.have.length(1))
      .then(() => agent.get('/uloskirjautuminen'))
      .then(() => knex('events').select().where({ type: 'logout_success' }))
      .then(events => events.should.have.length(1));
  });

  it('should be able to login and add a new ad', () => {
    const agent = chai.request.agent(server);
    return agent.get('/kirjaudu')
      .then(() => agent.post('/api/ilmoitukset').send({ heading: 'Otsikko', content: 'Sisältö' }))
      .then(res => knex('ads').where({ id: res.body }))
      .then(ad => ad[0].data.heading.should.equal('Otsikko'))
      .then(() => knex('ads').select())
      .then(ads => ads.should.have.length(4));
  });

  it('should be able to list all ads from API', () =>
    chai.request(server).get('/api/ilmoitukset')
      .then(res => {
        res.body.should.have.length(3);
        return res.should.be.json;
      })
  );

  it('should not be able to get a non-existing ad from API', done => {
    chai.request(server).get('/api/ilmoitukset/0')
      .end((err, res) => {
        expect(res).to.have.status(404);
        done();
      });
  });

  it('should be able to get an existing ad from API', () =>
    chai.request(server).get('/api/ilmoitukset/1')
      .then(res => {
        res.should.have.status(200);
        res.body.heading.should.equal('foo');
        return res.should.be.json;
      })
  );

  it('should not be able to get a report', done => {
    chai.request(server).get('/api/raportti')
      .end((err, res) => {
        res.should.have.status(403);
        done();
      });
  });

  it('should be able to login and get a report', () => {
    const agent = chai.request.agent(server);
    return agent.get('/kirjaudu')
      .then(() => agent.get('/api/raportti'))
      .then(res => {
        expect(res).to.have.status(200);
        return res.should.be.csv;
      });
  });
});
