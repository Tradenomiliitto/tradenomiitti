const uuid = require('uuid');
const request = require('request-promise-native');

let params;

function initialize(paramsIn) {
  params = paramsIn;
}

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
      obj[o.id] = o.otsikko;
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
          res.result.map(o => titles[o.sopimusala] || 'Tuntematon'));
}


function getUserPositions(id) {
  return Promise.all([
    getPositionTitles(),
    getUserEmploymentHistory(id)
  ]).then(([ titles, res ]) =>
          res.result.map(o => titles[o.tehtavanimike_val] || 'Tuntematon'));
}

function getUser(id) {
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

module.exports = {
  getUserPositions,
  getUserFirstName,
  getUserNickName,
  getUserDomains,
  getPositionTitles,
  getDomainTitles,
  initialize
}
