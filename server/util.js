module.exports = function initialize(params) {
  const knex = params.knex;

  function userForSession(req) {
    if (!req.session.id) return Promise.reject({ status: 403, msg: 'Request has no session id' });
    return knex('sessions')
      .where({ id: req.session.id })
      .then(resp => (resp.length === 0 ? Promise.reject({ status: 403, msg: 'No session found' }) : resp[0].user_id))
      .then(id => knex('users').where({ id }))
      .then(resp => resp[0]);
  }

  function userById(id) {
    return knex('users').where({ id }).then(resp => (resp[0]));
  }

  function loggedIn(req) {
    return userForSession(req)
      .then(() => true)
      .catch(() => false);
  }

  // formats user as json. isLoggedIn parameter decides if users name is shown in the json
  function formatUser(user, isLoggedIn) {
    const formattedUser = {};
    formattedUser.id = user.id;
    const userData = user.data;
    formattedUser.name = isLoggedIn ? (userData.name || '') : 'Mibiläinen';
    formattedUser.description = userData.description || '';
    formattedUser.title = userData.title || 'Ei titteliä';
    formattedUser.family_status = isLoggedIn ? userData.family_status : null;
    formattedUser.work_status = isLoggedIn ? userData.work_status : null;
    formattedUser.contribution = isLoggedIn ? userData.contribution : null;

    // only get these when getting detailed profile
    formattedUser.domains = [];
    formattedUser.positions = [];
    formattedUser.special_skills = [];
    formattedUser.education = [];

    formattedUser.location = userData.location || '';
    formattedUser.profile_creation_consented = userData.profile_creation_consented || false;
    formattedUser.cropped_picture = isLoggedIn ? (userData.cropped_picture || '') : '';

    return formattedUser;
  }

  function formatBusinessCard(dbCard) {
    const formatted = {};
    formatted.name = dbCard.name || '';
    formatted.title = dbCard.title || '';
    formatted.location = dbCard.location || '';
    formatted.phone = dbCard.phone || '';
    formatted.email = dbCard.email || '';
    formatted.linkedin = dbCard.linkedin || '';

    return formatted;
  }

  function formatAd(databaseAd, isLoggedIn) {
    return Promise.all([
      knex('answers').where({ ad_id: databaseAd.id })
        .then(answers =>
          Promise.all(answers.map(databaseAnswer => formatAnswer(databaseAnswer, isLoggedIn)))),
      knex('users').where({ id: databaseAd.user_id }).then(rows => rows[0]),
    ]).then(([answers, askingUser]) => {
      const ad = {};
      ad.id = databaseAd.id;
      ad.heading = databaseAd.data.heading || '';
      ad.content = databaseAd.data.content || '';
      ad.domain = databaseAd.data.domain;
      ad.position = databaseAd.data.position;
      ad.location = databaseAd.data.location;
      ad.created_by = formatUser(askingUser, isLoggedIn);
      ad.created_at = databaseAd.created_at;
      ad.answers = isLoggedIn ? answers : answers.length;
      return ad;
    });
  }


  function formatAnswer(databaseAnswer, isLoggedIn) {
    return knex('users').where({ id: databaseAnswer.user_id })
      .then(rows => rows[0])
      .then(user => {
        const answer = {};
        answer.created_by = formatUser(user, isLoggedIn);
        answer.content = databaseAnswer.data.content || '';
        answer.id = databaseAnswer.id;
        answer.created_at = databaseAnswer.created_at;
        return answer;
      });
  }

  function formatSettings(settingsIn) {
    const settings = {};
    const dbSettings = settingsIn || {};
    const trueFallback = value => (value === undefined ? true : value);
    settings.emails_for_answers = trueFallback(dbSettings.emails_for_answers);
    settings.emails_for_businesscards = trueFallback(dbSettings.emails_for_businesscards);
    settings.emails_for_new_ads = trueFallback(dbSettings.emails_for_new_ads);
    settings.email_address = dbSettings.email_address || '';
    return settings;
  }

  function logValue(tag, value) {
    const loggedValue = (arguments.length === 1) ? tag : value;
    if (loggedValue === tag) {
      console.log('LOG VALUE', loggedValue);
    } else {
      console.log(tag, value);
    }
    return loggedValue;
  }

  function patchSkillsToUser(user, skills) {
    /* eslint-disable no-param-reassign */
    user.domains = skills
      .filter(s => s.type === 'domain')
      .map(s => ({ heading: s.heading, skill_level: s.level }));

    user.positions = skills
      .filter(s => s.type === 'position')
      .map(s => ({ heading: s.heading, skill_level: s.level }));
    /* eslint-enable */
  }

  return {
    userForSession,
    userById,
    formatUser,
    formatBusinessCard,
    formatAd,
    formatAnswer,
    formatSettings,
    loggedIn,
    logValue,
    patchSkillsToUser,
  };
};
