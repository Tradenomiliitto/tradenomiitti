const uuid = require('uuid');
const request = require('request');


module.exports = function initialize(params) {
  const communicationsKey = params.communicationsKey;
  const knex = params.knex;
  const sebacon = params.sebacon;

  function login(req, res, next) {
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

      // http://stackoverflow.com/a/14438954/1517818
      const unique = (value, i, array) => array.indexOf(value) === i;

      const sessionId = uuid.v4();
      const remoteId = body.result.local_id;
      return knex('users').where({ remote_id: remoteId })
        .then((resp) => {
          if (resp.length === 0) {
            return Promise.all([
              sebacon.getUserFirstName(remoteId),
              sebacon.getUserNickName(remoteId),
              sebacon.getUserLastName(remoteId),
              sebacon.getUserEmail(remoteId),
              sebacon.getUserPhoneNumber(remoteId)
            ]).then(([firstname, nickname, lastname, email, phone]) => {
              return knex('users')
                .insert({
                  remote_id: body.result.local_id,
                  data: {
                    name: nickname || firstname,
                    domains: [],
                    positions: [],
                    profile_creation_consented: false,
                    business_card: {
                      name: `${firstname} ${lastname}`, // This works for most Finnish names
                      phone: phone,
                      email: email
                    }
                  },
                  settings: {
                    email_address: email,
                    emails_for_answers: true
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
        }).catch(next)
    });
  }

  function logout(req, res, next) {
    const sessionId = req.session.id || 'nosession';
    req.session = null;
    return knex('sessions').where({id: sessionId}).del()
      .then(() => res.redirect('https://tunnistus.avoine.fi/sso-logout/'))
      .catch(next);
  }

  return {
    login,
    logout
  };
}
