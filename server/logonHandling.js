const uuid = require('uuid');
const request = require('request');


module.exports = function initialize(params) {
  const {communicationsKey, knex, sebacon, restrictToGroup, testLogin} = params;

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

    const moreDataReq = Object.assign({}, validationReq, { method: "GetUserData" });

    request.post({
      url: 'https://tunnistus.avoine.fi/mmserver',
      json: validationReq
    }, (err, response, validationBody) => {
      if (err) {
        console.error(err);
        return res.status(500).send('Jotain meni pieleen');
      }

      if (validationBody.error) {
        console.error(validationBody);
        req.session = null;
        return res.status(400).send('Kirjautuminen epäonnistui');
      }

      request.post({
        url: 'https://tunnistus.avoine.fi/mmserver',
        json: moreDataReq
      }, (err, response, detailsBody) => {
        if (err) {
          console.error(err);
          return res.status(500).send('Jotain meni pieleen');
        }

        if (detailsBody.error) {
          console.error(detailsBody);
          req.session = null;
          return res.status(400).send('Kirjautuminen epäonnistui');
        }

        if (restrictToGroup && !detailsBody.result.groups.includes(restrictToGroup)) {
          console.log(detailsBody);
          req.session = null;
          return res.status(403).send('Ei oikeutta käyttää palvelua')
        }

        const sessionId = uuid.v4();
        const remoteId = validationBody.result.local_id;
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
                    remote_id: validationBody.result.local_id,
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
                    // postgres does not automatically return the id, ask for it explicitly
                  }, 'id').then(insertResp => ({
                    id: insertResp[0]
                  }))
                // insert will fail if user with the remote_id is already created
                // catch here so we don't catch sebacon errors that we want to go through to global error handling
                  .catch(e => knex('users').where({remote_id: remoteId}).then(rows => rows[0]))
              })
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
    });
  }

  function logout(req, res, next) {
    const sessionId = req.session.id;
    req.session = null;
    if (!testLogin) {
      if (sessionId) {
        return knex('sessions').where({id: sessionId}).del()
          .then(() => res.redirect('https://tunnistus.avoine.fi/sso-logout/'))
          .catch(next);
      } else {
        res.redirect('https://tunnistus.avoine.fi/sso-logout/');
      }
    } else {
      res.redirect('/');
    }
  }

  return {
    login,
    logout
  };
}
