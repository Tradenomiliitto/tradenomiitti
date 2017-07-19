/* global describe, beforeEach, afterEach, it */
const knex_config = require('../../knexfile');
const knex = require('knex')(knex_config.test);

const util = require('../util')({ knex });
const service = require('./ads')({ knex, util });

describe('Handle ads', () => {
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


  it('should list ads sorted by creation date in descending order', () =>
    service.listAds(false).then(ads =>
      ads.map(ad => ad.id).should.eql([2, 3, 1])
    )
  );

  it('should list ads sorted by creation date in ascending order', () =>
    service.listAds(false, undefined, undefined, undefined, undefined, undefined, 'created_at_asc').then(ads =>
      ads.map(ad => ad.id).should.eql([1, 3, 2])
    )
  );

  it('should list ads sorted by answer count in descending order', () =>
    service.listAds(false, undefined, undefined, undefined, undefined, undefined, 'answers_desc').then(ads =>
      ads.map(ad => ad.id).should.eql([3, 1, 2])
    )
  );

  it('should list ads sorted by answer count in ascending order', () =>
    service.listAds(false, undefined, undefined, undefined, undefined, undefined, 'answers_asc').then(ads =>
      ads.map(ad => ad.id).should.eql([2, 3, 1])
    )
  );

  it('should list ads sorted by newest answer date in descending order', () =>
    service.listAds(false, undefined, undefined, undefined, undefined, undefined, 'newest_answer_desc').then(ads =>
      ads.map(ad => ad.id).should.eql([1, 3, 2])
    )
  );

  it('should respect limit and offset', () => {
    const limit = 1;
    const offset = 2;
    return service.listAds(false, limit, offset).then(ads => {
      ads.should.have.length(1);
      return ads[0].id.should.equal(1);
    });
  });
});
