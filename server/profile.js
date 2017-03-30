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

  function getMe(req, res) {
    if (!req.session || !req.session.id) {
      return res.sendStatus(403);
    }
    return util.userForSession(req)
      .then(user => {
        return Promise.all([
          sebacon.getUserFirstName(user.remote_id),
          sebacon.getUserNickName(user.remote_id),
          sebacon.getUserEmploymentExtras(user.remote_id),
          user
        ])
      })
      .then(([ firstname, nickname, { positions, domains }, databaseUser ]) => {

        const user = util.formatUser(databaseUser, true);

        if (!databaseUser.data.business_card) {
          user.business_card = emptyBusinessCard;
        } else {
          user.business_card = databaseUser.data.business_card;
        }

        user.extra = {
          first_name: firstname,
          nick_name: nickname,
          positions: positions,
          domains: domains
        }
        if (databaseUser.data.picture_editing)
          user.picture_editing = databaseUser.data.picture_editing;

        return res.json(user);
      })
      .catch((err) => {
        console.error('Error in /api/me', err);
        req.session = null;
        res.sendStatus(500);
      });
  }

  const emptyBusinessCard = 
    {
      name: '',
      title: '',
      location: '',
      phone: '',
      email: ''
    }

  function putMe(req, res) {
    if (!req.session || !req.session.id) {
      return res.sendStatus(403);
    }

    return util.userForSession(req)
      .then(user => {
        const newData = Object.assign({}, user.data, req.body);

        return knex('users').where({ id: user.id }).update('data', newData);
      }).then(resp => {
        res.sendStatus(200);
      }).catch(err => {
        console.error(err);
        res.sendStatus(500);
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

    return withPossibleCrop
      .resize(size) // width size, keep aspect ratio
      .toBuffer((err, buffer) => {
        if (err) {
          console.error(err);
          return res.sendStatus(500);
        }
        const hash = crypto.createHash('sha1');
        hash.update(buffer);

        const fileName = `${hash.digest('hex')}.${extension}`;
        const fullPath = `${userImagesPath}/${fileName}`;

        return gm(buffer).write(fullPath, (err) => {
          if (err) {
            console.error(err);
            return res.sendStatus(500);
          }
          return res.send(fileName);
        })
      });
  }

  function putImage(req, res) {
    if (!req.files || !req.files.image)
      return res.status(400).send('No image found');

    const originalBuffer = req.files.image.data;
    return putAnyimage(req, res, 1024, originalBuffer, null);
  }

  function putCroppedImage(req, res) {
    const crop = {
      width: req.query.width,
      height: req.query.height,
      x: req.query.x,
      y: req.query.y
    };

    const fullPath = `${userImagesPath}/${req.query.fileName}`;
    gm(fullPath).toBuffer((err, buffer) => {
      if (err) {
        console.error('PUT Cropped Image', err);
        return res.sendStatus(500);
      }
      return putAnyimage(req, res, 250, buffer, crop);
    });
  }

  function consentToProfileCreation(req, res) {
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
        res.sendStatus(200);
      }).catch(err => {
        console.error('Error in /api/profiilit/luo', err);
        res.sendStatus(500);
      });
  }

  function listProfiles(req, res) {
    util.loggedIn(req)
      .then(loggedIn => service.listProfiles(loggedIn, req.query.limit, req.query.offset))
      .then(users => res.json(users))
      .catch(err => {
        console.error(err);
        res.sendStatus(500);
      })
  }

  function getProfile(req, res) {
    return Promise.all([ knex('users').where('id', req.params.id).first(), util.loggedIn(req)])
      .then(([ user, loggedIn ]) => util.formatUser(user, loggedIn))
      .then(user => res.json(user))
      .catch(err => {
        return res.sendStatus(404)
      });
  }

  //gives business card from session user to user, whose id is given in request params
  function addContact(req, res) {
    return util.userForSession(req)
      .then(user => {
        if (user.id == req.params.user_id) {
          return Promise.reject("User cannot add contact to himself");
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
              emails.sendNotificationForContact(receiver, user);
              return res.status(200).send();
            })
        }
        else {
          return Promise.reject("User has already given their business card to this user");
        }
      })
      .catch(e => {
        console.log("Add contact error: " + e);
        return res.status(400).send();
      })
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
