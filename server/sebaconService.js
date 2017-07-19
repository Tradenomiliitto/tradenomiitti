const uuid = require('uuid');
const request = require('request-promise-native');

module.exports = function initialize(params) {
  const { adminGroup, disable, testLogin } = params;

  function url() {
    return `https://voltage.sebacon.net/SebaconAPI/?auth=${params.auth}`;
  }

  function getMetaList(meta, fuzzCapitalisation) {
    return request.post({
      url: url(),
      auth: {
        user: `${params.customer}\\${params.user}`,
        pass: `${params.password}`,
      },
      json: {
        id: uuid.v4(),
        jsonrpc: '2.0',
        method: 'getApplicationObjectMeta',
        params: [meta],
      },
    }).then(res => {
      const obj = {};
      res.result.forEach(o => {
        const str = o.otsikko;
        obj[o.id] = fuzzCapitalisation
          ? str.charAt(0).toLocaleUpperCase() + str.slice(1).toLocaleLowerCase()
          : str;
      });
      return obj;
    });
  }

  function getPositionTitles() {
    return getMetaList('tehtavanimikkeet', false);
  }

  function getDomainTitles() {
    return getMetaList('sopimusalat', true);
  }

  function getGeoAreas() {
    return getMetaList('maakunnat', false);
  }

  function getUserEmploymentHistory(id) {
    return request.post({
      url: url(),
      auth: {
        user: `${params.customer}\\${params.user}`,
        pass: `${params.password}`,
      },
      json: {
        id: uuid.v4(),
        jsonrpc: '2.0',
        method: 'getPersonObject',
        params: [
          id,
          'tyosuhteet',
        ],
      },
    });
  }

  function getUserEmploymentExtras(id) {
    if (disable) return Promise.resolve({ domains: [], positions: [] });

    return Promise.all([
      getDomainTitles(),
      getPositionTitles(),
      getUserEmploymentHistory(id),
    ]).then(([domainTitles, positionTitles, res]) => {
      const organisations = Promise.all(
        res.result.map(o =>
          getOrganisation(o.tyonantaja)
            .then(({ result }) => result.name || 'Tuntematon')
        )
      );
      return Promise.all([domainTitles, positionTitles, res, organisations]);
    }).then(([domainTitles, positionTitles, res, organisations]) => ({
      domains: res.result
        .map((o, i) => `${domainTitles[o.sopimusala] || 'Tuntematon'} (${organisations[i]})`),
      positions: res.result
        .map((o, i) => `${positionTitles[o.tehtavanimike_val] || 'Tuntematon'} (${organisations[i]})`),
    }));
  }

  function getUser(id) {
    return getObject(id, 'getPersonObject');
  }

  function getOrganisation(id) {
    return getObject(id, 'getOrganisationObject');
  }

  function isAdmin(id) {
    // if sebacon is disabled or we don't have a known admin group, nobody is admin
    // - expect the first test user if testLogin is enabled
    if (disable && testLogin && id === '-1') {
      return Promise.resolve(true);
    } else if (disable || !adminGroup) {
      return Promise.resolve(false);
    }

    return getObject(id, 'getData')
      .then(o => o.result.groups.includes(adminGroup));
  }

  function getObject(id, method) {
    return request.post({
      url: url(),
      auth: {
        user: `${params.customer}\\${params.user}`,
        pass: `${params.password}`,
      },
      json: {
        id: uuid.v4(),
        jsonrpc: '2.0',
        method,
        params: [
          id,
        ],
      },
    });
  }

  function getUserFirstName(id) {
    if (disable) return Promise.resolve('');

    return getUser(id)
      .then(res => res.result.firstname || '');
  }

  function getUserNickName(id) {
    if (disable) return Promise.resolve('');

    return getUser(id)
      .then(res => res.result.kutsumanimi || '');
  }

  function getUserLastName(id) {
    if (disable) return Promise.resolve('');

    return getUser(id)
      .then(res => res.result.lastname || '');
  }

  function getUserEmail(id) {
    if (disable) return Promise.resolve('');

    return getUser(id)
      .then(res => res.result.email1 || res.result.email2 || '');
  }

  function getUserPhoneNumber(id) {
    if (disable) return Promise.resolve('');

    return getUser(id)
      .then(res => res.result.matkapuhelin || '');
  }

  function getUserGeoArea(id) {
    if (disable) return Promise.resolve('');

    return Promise.all([
      getGeoAreas(),
      getUser(id),
    ]).then(([titles, res]) => titles[res.result.maakunta || ''] || '');
  }

  return {
    getUserFirstName,
    getUserNickName,
    getUserLastName,
    getUserEmploymentExtras,
    getUserEmail,
    getUserPhoneNumber,
    getPositionTitles,
    getUserGeoArea,
    getDomainTitles,
    isAdmin,
  };
};
