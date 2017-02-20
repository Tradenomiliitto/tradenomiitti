const uuid = require('uuid');
const request = require('request-promise-native');

let params;

function initialize(paramsIn) {
  params = paramsIn;
}

function url() {
  return `https://voltage.sebacon.net/SebaconAPI/?auth=${params.auth}`;
}

function getPositionTitles() {
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
      params: ['tehtavanimikkeet']
    }
  }).then(res => {
    const obj = {};
    res.result.forEach(o => {
      obj[o.id] = o.otsikko;
    });
    return obj;
  })
}

function getUserPositions(id) {
  return Promise.all([
    getPositionTitles(),
    request.post({
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
    })
  ]).then(([ titles, res ]) => res.result.map(o => titles[o.tehtavanimike_val]));
}

function getUserFirstName(id) {
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
  }).then(res => res.result.kutsumanimi || res.result.firstname);
}

module.exports = {
  getUserPositions,
  getUserFirstName,
  initialize
}
