const crypto = require('crypto');
const gm = require('gm'); // Graphics Magick
const getFileType = require('file-type').fromBuffer;


module.exports = function initialize(params) {
  const knex = params.knex;
  const sebacon = params.sebacon;
  const util = params.util;
  const userImagesPath = params.userImagesPath;
  const emails = params.emails;
  const service = require('./services/profiles')({ knex, util, emails });

  function getMe(req, res, next) {
    if (!req.session || !req.session.id) {
      return res.sendStatus(401);
    }
    return util
      .userForSession(req)
      .then(user =>
        Promise.all([
          sebacon.getUserFirstName(user.remote_id),
          sebacon.getUserNickName(user.remote_id),
          sebacon.getUserLastName(user.remote_id),
          sebacon.getUserEmploymentExtras(user.remote_id),
          sebacon.getUserEmail(user.remote_id),
          sebacon.getUserPhoneNumber(user.remote_id),
          sebacon.getUserGeoArea(user.remote_id),
          service.profileSkills(user.id),
          service.profileSpecialSkills(user.id),
          service.profileEducations(user.id),
          sebacon.isAdmin(user.remote_id),
          user,
        ])
      )
      .then(
        ([
          firstname,
          nickname,
          lastname,
          { positions, domains },
          email,
          phone,
          geoArea,
          skills,
          specialSkills,
          educations,
          isAdmin,
          databaseUser,
        ]) => {
          const user = util.formatUser(databaseUser, true);

          if (!databaseUser.data.business_card) {
            user.business_card = util.formatBusinessCard({});
          } else {
            user.business_card = util.formatBusinessCard(
              databaseUser.data.business_card
            );
          }

          user.extra = {
            first_name: firstname,
            nick_name: nickname,
            last_name: lastname,
            positions,
            domains,
            email,
            phone,
            geo_area: geoArea,
          };

          user.is_admin = isAdmin;

          if (databaseUser.data.picture_editing) {
            user.picture_editing = databaseUser.data.picture_editing;
          }

          util.patchSkillsToUser(user, skills);

          user.education = educations;
          user.special_skills = specialSkills;

          return res.json(user);
        }
      )
      .catch(err => {
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

    return util
      .userForSession(req)
      .then(user => {
        const domains = req.body.domains;
        const positions = req.body.positions;
        const educations = req.body.education;
        const specialSkills = req.body.special_skills;

        const newData = Object.assign({}, user.data, req.body);
        // Don't save things saved elsewhere to data
        delete newData.domains;
        delete newData.positions;
        delete newData.education;
        delete newData.special_skills;

        return knex.transaction(trx =>
          trx('users')
            .where({ id: user.id })
            .update({
              data: newData,
              modified_at: new Date(),
            })
            .then(() => {
              if (!specialSkills || specialSkills.length === 0) {
                return null;
              }

              const insertObjects = specialSkills.map(title => ({
                category: 'Käyttäjien lisäämät',
                title,
              }));
              const insertPart = knex('special_skills')
                .insert(insertObjects)
                .toString();
              const query = `${insertPart} ON CONFLICT (title) DO NOTHING`;
              return knex.raw(query);
            })
            .then(() => {
              if (!educations || educations.length === 0) {
                return null;
              }

              const insertObjectLists = educations.map(o => {
                const makeObject = type =>
                  o[type]
                    ? {
                        type,
                        category: 'Käyttäjien lisäämät',
                        title: o[type],
                      }
                    : null;
                return [
                  makeObject('degree'),
                  makeObject('major'),
                  makeObject('specialization'),
                ].filter(x => x);
              });
              const insertObjects = [].concat(...insertObjectLists);
              // Check for a list of educations with only institutes chosen
              if (insertObjects.length === 0) {
                return null;
              }
              const insertPart = knex('education')
                .insert(insertObjects)
                .toString();
              const query = `${insertPart} ON CONFLICT (title, type) DO NOTHING`;
              return knex.raw(query);
            })
            .then(() =>
              trx('skills')
                .where({ user_id: user.id })
                .del()
            )
            .then(() =>
              trx('user_special_skills')
                .where({ user_id: user.id })
                .del()
            )
            .then(() =>
              trx('user_educations')
                .where({ user_id: user.id })
                .del()
            )
            .then(() => {
              const domainPromises = domains.map(domain =>
                trx('skills').insert({
                  user_id: user.id,
                  heading: domain.heading,
                  level: domain.skill_level,
                  type: 'domain',
                })
              );
              const positionPromises = positions.map(position =>
                trx('skills').insert({
                  user_id: user.id,
                  heading: position.heading,
                  level: position.skill_level,
                  type: 'position',
                })
              );
              const specialSkillPromises = specialSkills.map(skill =>
                trx('user_special_skills').insert({
                  user_id: user.id,
                  heading: skill,
                })
              );
              const educationPromises = educations.map(education =>
                trx('user_educations').insert({
                  user_id: user.id,
                  data: education,
                })
              );
              return Promise.all(
                domainPromises
                  .concat(positionPromises)
                  .concat(specialSkillPromises)
                  .concat(educationPromises)
              );
            })
            .then(() =>
              trx('events').insert({
                type: 'profile_save',
                data: { user_id: user.id },
              })
            )
        );
      })
      .then(() => res.sendStatus(200))
      .catch(next);
  }

  function deleteMe(req, res, next) {
    if (!req.session || !req.session.id) {
      return res.sendStatus(401);
    }
    return util.userForSession(req).then(user =>
      Promise.all([
        knex('users')
          .where({ id: user.id })
          .del(),
        knex('events').insert({
          type: 'delete_user',
          data: { user_id: user.id },
        }),
      ])
        .then(() => res.sendStatus(200))
        .catch(next)
    );
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
      gmObject.write(path, err => {
        if (err) reject(err);
        else resolve();
      });
    });
  }

  async function putAnyimage(req, res, size, originalBuffer, crop) {
    const extension = await getFileType(originalBuffer).then(ftype => ftype.ext);
    if (!['png', 'jpg', 'jpeg'].includes(extension)) {
      return Promise.resolve(res.status(400).send('Wrong file format'));
    }

    const commonTasks = gm(originalBuffer)
      .autoOrient() // avoid rotating exif issues
      .noProfile();

    const withPossibleCrop = crop
      ? commonTasks.crop(crop.width, crop.height, crop.x, crop.y)
      : commonTasks;

    return toBufferPromise(withPossibleCrop.resize(size)) // width size, keep aspect ratio
      .then(buffer => {
        const hash = crypto.createHash('sha1');
        hash.update(buffer);

        const fileName = `${hash.digest('hex')}.${extension}`;
        const fullPath = `${userImagesPath}/${fileName}`;

        return writePromise(gm(buffer), fullPath).then(() => fileName);
      })
      .then(filename =>
        knex('events').insert(
          { type: 'image_upload', data: { filename: filename } },
          'data'
        )
      )
      .then(data => res.send(data[0].filename));
  }

  function putImage(req, res, next) {
    if (!req.files || !req.files.image) {
      return res.status(400).send('No image found');
    }

    const originalBuffer = req.files.image.data;
    return putAnyimage(req, res, 1024, originalBuffer, null).catch(next);
  }

  function putCroppedImage(req, res, next) {
    const crop = {
      width: req.query.width,
      height: req.query.height,
      x: req.query.x,
      y: req.query.y,
    };

    const fullPath = `${userImagesPath}/${req.query.fileName}`;
    toBufferPromise(gm(fullPath))
      .then(buffer => putAnyimage(req, res, 250, buffer, crop))
      .catch(next);
  }

  function consentToProfileCreation(req, res, next) {
    if (!req.session || !req.session.id) {
      return res.sendStatus(403);
    }

    return util
      .userForSession(req)
      .then(user => {
        // patch user object
        Object.assign(user.data, { profile_creation_consented: true });
        return knex('users')
          .where({ id: user.id })
          .update('data', user.data);
      })
      .then(() => res.json('Ok')) // Elm Http.post expects Json
      .catch(next);
  }

  function listProfiles(req, res, next) {
    util
      .loggedIn(req)
      .then(loggedIn =>
        service.listProfiles(
          loggedIn,
          req.query.limit,
          req.query.offset,
          req.query || {}, // get filters from query object
          req.query.order
        )
      )
      .then(users => res.json(users))
      .catch(next);
  }

  function listContacts(req, res, next) {
    if (!req.session || !req.session.id) {
      return res.sendStatus(401);
    }
    return util
      .userForSession(req)
      .then(user => service.listContacts(user))
      .then(objects => res.json(objects))
      .catch(next);
  }

  function getProfile(req, res, next) {
    return Promise.all([util.userById(req.params.id), util.loggedIn(req)])
      .then(([user, loggedIn]) => {
        const formattedUser = util.formatUser(user, loggedIn);
        if (loggedIn) {
          return util.userForSession(req).then(loggedInUser => {
            const promises = [
              service.contactExists(loggedInUser, user),
              sebacon.isAdmin(loggedInUser.remote_id),
            ];
            return Promise.all(promises).then(([contactExists, isAdmin]) => {
              formattedUser.contacted = contactExists;
              if (isAdmin) {
                formattedUser.member_id = parseInt(user.remote_id, 10);
              }
              return formattedUser;
            });
          });
        }

        return formattedUser;
      })
      .then(user => {
        const promises = [
          service.profileSkills(user.id),
          service.profileSpecialSkills(user.id),
          service.profileEducations(user.id),
        ];
        return Promise.all(promises).then(
          ([skills, specialSkills, educations]) => {
            /* eslint-disable no-param-reassign */
            util.patchSkillsToUser(user, skills);
            user.education = educations;
            user.special_skills = specialSkills;
            /* eslint-enable */

            return user;
          }
        );
      })
      .then(user => res.json(user))
      .catch(err => {
        next({ status: 404, msg: err });
      });
  }

  // gives business card from session user to user, whose id is given in request params
  function addContact(req, res, next) {
    const introductionText = req.body.message;
    const toUserId = req.params.user_id;
    return util
      .userForSession(req)
      .then(user => service.addContact(user, toUserId, introductionText))
      .then(() => res.json('ok'))
      .catch(next);
  }

  return {
    getMe,
    putMe,
    putImage,
    putCroppedImage,
    deleteMe,
    consentToProfileCreation,
    listProfiles,
    getProfile,
    addContact,
    listContacts,
  };
};
