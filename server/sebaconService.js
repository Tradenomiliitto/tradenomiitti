const uuid = require('uuid');
const request = require('request-promise-native');

module.exports = function initialize(params) {
  function url() {
    return `https://voltage.sebacon.net/SebaconAPI/?auth=${params.auth}`;
  }

  function getMetaList(meta) {
    return request.post({
      url: url(),
      auth: {
        user: `${params.customer}\\${params.user}`,
        pass: `${params.password}`
      },
      json: {
        id: uuid.v4(),
        jsonrpc: '2.0',
        method: 'getApplicationObjectMeta',
        params: [ meta ]
      }
    }).then(res => {
      const obj = {};
      res.result.forEach(o => {
        const str = o.otsikko;
        obj[o.id] = str.charAt(0).toLocaleUpperCase() + str.slice(1).toLocaleLowerCase();
      });
      return obj;
    })
  }

  function getPositionTitles() {
    return getMetaList('tehtavanimikkeet');
  }

  function getDomainTitles() {
    return getMetaList('sopimusalat');
  }

  function getUserEmploymentHistory(id) {
    return request.post({
      url: url(),
      auth: {
        user: `${params.customer}\\${params.user}`,
        pass: `${params.password}`
      },
      json: {
        id: uuid.v4(),
        jsonrpc: '2.0',
        method: 'getPersonObject',
        params: [
          id,
          'tyosuhteet'
        ]
      }
    });
  }

  function getUserDomains(id) {
    return Promise.all([
      getDomainTitles(),
      getUserEmploymentHistory(id)
    ]).then(([ titles, res ]) =>
            res.result
            .map(o => titles[o.sopimusala])
            .filter(x => x));
  }

  function getUserEmploymentExtras(id) {
    return Promise.all([
      getDomainTitles(),
      getPositionTitles(),
      getUserEmploymentHistory(id)
    ]).then(([ domainTitles, positionTitles, res ]) => {
      const organisations = Promise.all(
        res.result.map(o => getOrganisation(o.tyonantaja).then(o => o.result.name || 'Tuntematon')));
      return Promise.all([ domainTitles, positionTitles, res, organisations ]);
    }).then(([ domainTitles, positionTitles, res, organisations ]) => {
      return {
        domains: res.result
          .map((o, i) => (domainTitles[o.sopimusala] || 'Tuntematon') +
              ` (${organisations[i]})`
              ),
        positions: res.result
          .map((o, i) => (positionTitles[o.tehtavanimike_val] || 'Tuntematon') +
              ` (${organisations[i]})`
              )
      }
    })
  }


  function getUserPositions(id) {
    return Promise.all([
      getPositionTitles(),
      getUserEmploymentHistory(id)
    ]).then(([ titles, res ]) =>
            res.result
              .map(o => titles[o.tehtavanimike_val])
              .filter(x => x));
  }

  function getUser(id) {
    return getObject(id, 'getPersonObject');
  }


  function getOrganisation(id) {
    return getObject(id, 'getOrganisationObject');
  }

  function getObject(id, method) {
    return request.post({
      url: url(),
      auth: {
        user: `${params.customer}\\${params.user}`,
        pass: `${params.password}`
      },
      json: {
        id: uuid.v4(),
        jsonrpc: '2.0',
        method,
        params: [
          id
        ]
      }
    });
  }

  function getUserFirstName(id) {
    return getUser(id)
      .then(res => res.result.firstname || '');
  }

  function getUserNickName(id) {
    return getUser(id)
      .then(res => res.result.kutsumanimi || '');
  }

  return {
    getUserPositions,
    getUserFirstName,
    getUserNickName,
    getUserDomains,
    getUserEmploymentExtras,
    getPositionTitles,
    getDomainTitles,
    initialize
  }
}
