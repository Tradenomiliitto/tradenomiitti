/* global describe, beforeEach, afterEach, it */

const moment = require('moment');
const MockDate = require('mockdate');

const knex_config = require('../../knexfile');
const knex = require('knex')(knex_config.test);

const util = require('../util')({ knex });

const rootDir = './frontend';
const staticDir = process.env.NON_LOCAL ? '/srv/static' : `${rootDir}/static`;
const emails = require('../emails')({ enableEmailGlobally: false, util, staticDir });
const service = require('./profiles')({ knex, util, emails });

const aDate = new Date('2018-01-13T11:00:00.000Z');

describe('Handle users', () => {
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


  it('should list users', () => service.listProfiles(false).then(users =>
    users.map(user => user.id).should.include(1)
  ));

  it('should respect limit and offset', () => {
    const limit = 0;
    const offset = 0;
    return service.listProfiles(false, limit, offset).then(users =>
      users.should.have.length(0)
    );
  });

  function insertAndList(sort) {
    MockDate.set(aDate);
    return knex('users')
      .insert({ id: 3,
        remote_id: -3,
        data: {
          name: 'Ökynomi',
        },
        settings: {},
        modified_at: moment(),
      })
      .then(() => service.listProfiles(true, undefined, undefined, {}, sort));
  }

  it('should sort by activity by default', () => insertAndList(undefined).then(users => {
    users.should.have.length(3);
    return users[0].id.should.equal(3);
  }));

  it('should sort by activity when asked', () => insertAndList('recent').then(users => {
    users.should.have.length(3);
    return users[0].id.should.equal(3);
  }));

  it('should sort by name descending', () => insertAndList('alphaDesc').then(users => {
    users.should.have.length(3);
    return users[0].id.should.equal(3);
  }));

  it('should sort by name ascending', () => insertAndList('alphaAsc').then(users => {
    users.should.have.length(3);
    return users[2].id.should.equal(3);
  }));
  it('should filter by location', () => {
    MockDate.set(aDate);
    return knex('users')
      .insert({ id: 3,
        remote_id: -3,
        data: {
          location: 'siellätäällä',
        },
        settings: {},
        modified_at: moment(),
      })
      .then(() => service.listProfiles(false, undefined, undefined, { location: 'siellätäällä' }, 'recent')).then(users => {
        users.should.have.length(1);
        return users[0].id.should.equal(3);
      });
  });
});

describe('Handle contacts', () => {
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


  it('should list contacts sent by others to logged in user', () => Promise.all([util.userById(1), util.userById(2)])
    .then(([loggedInUser, otherUser]) =>
      service.addContact(loggedInUser, otherUser.id, 'intro text longer than 10 chars')
        .then(() => Promise.all([
          service.listContacts(loggedInUser),
          service.listContacts(otherUser),
        ]))
        .then(([contactsOfLoggedIn, contactsOfOther]) => {
          contactsOfLoggedIn.should.have.length(0);
          contactsOfOther.should.have.length(1);
          return contactsOfOther[0].user.id.should.equal(loggedInUser.id);
        })
    )
  );
});
