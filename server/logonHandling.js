const uuid = require('uuid');
const request = require('request');


module.exports = function initialize(params) {
  const communicationsKey = params.communicationsKey;
  const knex = params.knex;
  const sebacon = params.sebacon;

  function login(req, res) {
    const ssoId = req.body.ssoid;
    const validationReq = {
      id: uuid.v4(),
      method: "GetUser",
      params: [
        communicationsKey,
        ssoId
      ],
      jsonrpc: "2.0"
    };
    request.post({
      url: 'https://tunnistus.avoine.fi/mmserver',
      json: validationReq
    }, (err, response, body) => {
      if (err) {
        console.error(err);
        return res.status(500).send('Jotain meni pieleen');
      }

      if (body.error) {
        console.log(body);
        req.session = null;
        return res.status(400).send('Kirjautuminen epäonnistui');
      }

      const sessionId = uuid.v4();
      const remoteId = body.result.local_id;
      return knex('users').where({ remote_id: remoteId })
        .then((resp) => {
          if (resp.length === 0) {
            return Promise.all([
              sebacon.getUserFirstName(remoteId),
              sebacon.getUserNickName(remoteId),
              sebacon.getUserPositions(remoteId),
              sebacon.getUserDomains(remoteId)
            ]).then(([firstname, nickname, positions, domains]) => {
              return knex('users')
                .insert({
                  remote_id: body.result.local_id,
                  data: {
                    name: nickname || firstname,
                    domains: domains.map(d => ({ heading: d, skill_level: 1 })),
                    positions: positions.map(d => ({ heading: d, skill_level: 1 })),
                    profile_creation_consented: false
                  }
                }, 'id') // postgres does not automatically return the id, ask for it explicitly
            }).then(insertResp => ({ id: insertResp[0] }))
              //insert will fail if user with the remote_id is already created
              .catch(e => knex('users').where({remote_id: remoteId})
                .then(rows => rows[0]))
          } else {
            return resp[0];
          }
        })
        .then((user) => {
          return knex('sessions').insert({
            id: sessionId,
            user_id: user.id
          }).then(() => {
            req.session.id = sessionId;
            return res.redirect(req.query.path || '/');
          });
        })
    });
  }

  function logout(req, res) {
    const sessionId = req.session.id || 'nosession';
    req.session = null;
    return knex('sessions').where({id: sessionId}).del()
      .then(() => res.redirect('https://tunnistus.avoine.fi/sso-logout/'));
  }

  return {
    login,
    logout
  };
}
