const crypto = require('crypto');
const gm = require('gm'); // Graphics Magick
const getFileType = require('file-type');


module.exports = function initialize(params) {
  const knex = params.knex;
  const sebacon = params.sebacon;
  const util = params.util;
  const userImagesPath = params.userImagesPath;
  const emails = params.emails;
  const service = require('./services/profiles')({ knex, util });

  function getMe(req, res, next) {
    if (!req.session || !req.session.id) {
      return res.sendStatus(401);
    }
    return util.userForSession(req)
      .then(user => {
        return Promise.all([
          sebacon.getUserFirstName(user.remote_id),
          sebacon.getUserNickName(user.remote_id),
          sebacon.getUserLastName(user.remote_id),
          sebacon.getUserEmploymentExtras(user.remote_id),
          sebacon.getUserEmail(user.remote_id),
          sebacon.getUserPhoneNumber(user.remote_id),
          sebacon.getUserGeoArea(user.remote_id),
          service.profileSkills(user.id),
          user
        ])
      })
      .then(([ firstname, nickname, lastname, { positions, domains }, email, phone, geoArea, skills, databaseUser ]) => {

        const user = util.formatUser(databaseUser, true);

        if (!databaseUser.data.business_card) {
          user.business_card = util.formatBusinessCard({});
        } else {
          user.business_card = util.formatBusinessCard(databaseUser.data.business_card);
        }

        user.extra = {
          first_name: firstname,
          nick_name: nickname,
          last_name: lastname,
          positions,
          domains,
          email,
          phone,
          geo_area: geoArea
        }
        if (databaseUser.data.picture_editing)
          user.picture_editing = databaseUser.data.picture_editing;

        user.domains = skills
          .filter(s => s.type === 'domain')
          .map(s => ({ heading: s.heading, skill_level: s.level }));

        user.positions = skills
          .filter(s => s.type === 'position')
          .map(s => ({ heading: s.heading, skill_level: s.level }));

        return res.json(user);
      })
      .catch((err) => {
        if (err.status === 403) {
          req.session = null;
          return res.sendStatus(err.status);
        }
        // fall back to default error handler for errors other than session missing from db
        return next(err);
      });
  }

  function putMe(req, res, next) {
    if (!req.session || !req.session.id) {
      return res.sendStatus(403);
    }

    return util.userForSession(req)
      .then(user => {
        const newData = Object.assign({}, user.data, req.body);

        return knex.transaction(trx => {
          return trx('users')
            .where({ id: user.id })
            .update('data', newData)
            .then(() => trx('skills').where({ user_id: user.id }).del())
            .then(() => {
              const domainPromises = newData.domains.map(domain => {
                return trx('skills').insert({
                  user_id: user.id,
                  heading: domain.heading,
                  level: domain.skill_level,
                  type: 'domain'
                })
              });
              const positionPromises = newData.positions.map(position => {
                return trx('skills').insert({
                  user_id: user.id,
                  heading: position.heading,
                  level: position.skill_level,
                  type: 'position'
                });
              });
              return Promise.all(domainPromises.concat(positionPromises));
            });
        })
      }).then(resp => {
        res.sendStatus(200);
      }).catch(next)
  }

  function toBufferPromise(gmObject) {
    return new Promise((resolve, reject) => {
      gmObject.toBuffer((err, buffer) => {
        if (err) reject(err);
        else resolve(buffer);
      });
    });
  }

  function writePromise(gmObject, path) {
    return new Promise((resolve, reject) => {
      gmObject.write(path, (err) => {
        if (err) reject(err);
        else resolve();
      })
    })
  }

  function putAnyimage(req, res, size, originalBuffer, crop) {
    const fileType = getFileType(originalBuffer);
    const extension = fileType && fileType.ext;
    if (!['png', 'jpg'].includes(extension))
      return res.status(400).send('Wrong file format');

    const commonTasks = gm(originalBuffer)
          .autoOrient() // avoid rotating exif issues
          .noProfile();

    const withPossibleCrop = crop
          ? commonTasks.crop(crop.width, crop.height, crop.x, crop.y)
          : commonTasks;

    return toBufferPromise(withPossibleCrop
      .resize(size)) // width size, keep aspect ratio
      .then(buffer => {
        const hash = crypto.createHash('sha1');
        hash.update(buffer);

        const fileName = `${hash.digest('hex')}.${extension}`;
        const fullPath = `${userImagesPath}/${fileName}`;

        return writePromise(gm(buffer), fullPath)
          .then(() => fileName)
      }).then(fileName => {
        return res.send(fileName);
      })
  }

  function putImage(req, res, next) {
    if (!req.files || !req.files.image)
      return res.status(400).send('No image found');

    const originalBuffer = req.files.image.data;
    return putAnyimage(req, res, 1024, originalBuffer, null)
      .catch(next);
  }

  function putCroppedImage(req, res, next) {
    const crop = {
      width: req.query.width,
      height: req.query.height,
      x: req.query.x,
      y: req.query.y
    };

    const fullPath = `${userImagesPath}/${req.query.fileName}`;
    toBufferPromise(gm(fullPath)).then(buffer => {
      return putAnyimage(req, res, 250, buffer, crop);
    }).catch(next);
  }

  function consentToProfileCreation(req, res, next) {
    if (!req.session || !req.session.id) {
      return res.sendStatus(403);
    }

    return util.userForSession(req)
      .then(user => {
        // patch user object
        Object.assign(user.data, {profile_creation_consented: true});
        return knex('users')
          .where({ id: user.id })
          .update('data', user.data)
      }).then(resp => {
        res.json("Ok"); // Elm Http.post expects Json
      }).catch(next);
  }

  function listProfiles(req, res, next) {
    util.loggedIn(req)
      .then(loggedIn => service.listProfiles(loggedIn, req.query.limit, req.query.offset))
      .then(users => res.json(users))
      .catch(next)
  }

  function getProfile(req, res, next) {
    return Promise.all([ util.userById(req.params.id),
                         util.loggedIn(req)
                       ])
      .then(([ user, loggedIn ]) => {
        if (loggedIn) {
          // this trainwreck checks whether the logged in user
          // has shared their business card with the requested user
          return util.userForSession(req).then(loggedInUser => {
            return knex('contacts').where({
              from_user: loggedInUser.id,
              to_user: user.id
            }).then(resp => resp.length > 0)
              .then(contactExists => {
                const formattedUser = util.formatUser(user, loggedIn)
                formattedUser.contacted = contactExists;
                return formattedUser;
              })
          })
        }

        return util.formatUser(user, loggedIn);
      }).then(user => {
        return service.profileSkills(user.id).then(skills => {
          user.domains = skills
            .filter(s => s.type === 'domain')
            .map(s => ({ heading: s.heading, skill_level: s.level }));

          user.positions = skills
            .filter(s => s.type === 'position')
            .map(s => ({ heading: s.heading, skill_level: s.level }));

          return user
        });
      }).then(user => res.json(user))
      .catch(err => {
        next({ status: 404, msg: err})
      });
  }

  //gives business card from session user to user, whose id is given in request params
  function addContact(req, res, next) {
    const introductionText = req.body.message;
    if (typeof introductionText !== 'string' || introductionText.length < 10) {
      return Promise.reject({ status: 400, msg: 'Introduction text is mandatory'});
    }

    return util.userForSession(req)
      .then(user => {
        if (user.id == req.params.user_id) {
          return Promise.reject({ status: 400, msg: 'User cannot add contact to himself' });
        }
        const businessCard = util.formatBusinessCard(user.data.business_card);
        if(!businessCard) {
          return Promise.reject('User has no business card');
        }
        if(businessCard.phone.length === 0 && businessCard.email.length === 0) {
          return Promise.reject('User is missing details from business card');
        }
        return user;
      })
      .then(user =>
        Promise.all(
          [ knex('contacts').where({ from_user: user.id, to_user: req.params.user_id }),
            Promise.resolve(user) ]))
      .then(([resp, user]) => {
        if (resp.length == 0) {
          knex('contacts').insert({ from_user: user.id, to_user: req.params.user_id })
            .then(_ => util.userById(req.params.user_id))
            .then(receiver => {
              emails.sendNotificationForContact(receiver, user, introductionText);
              return res.json("Ok");
            })
        }
        else {
          return Promise.reject("User has already given their business card to this user");
        }
      })
      .catch(next)
  }

  return {
    getMe,
    putMe,
    putImage,
    putCroppedImage,
    consentToProfileCreation,
    listProfiles,
    getProfile,
    addContact
  };
}
