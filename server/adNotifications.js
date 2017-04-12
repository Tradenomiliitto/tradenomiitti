module.exports = function init(params) {
  const emails = params.emails;
  const knex = params.knex;
  const util = params.util;
  const service = require('./services/adNotifications')({ knex, util });

  function testSending(req, res, next) {
    service.notificationObjects()
      .then(objects => res.json(objects))
  }

  return {
    testSending
  };
}
