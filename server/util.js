module.exports = function initialize(params) {
  const knex = params.knex;

  function userForSession(req) {
    if (!req.session.id) return Promise.reject('Request has no session id');
    return knex('sessions')
      .where({ id: req.session.id })
      .then(resp => resp.length === 0 ? Promise.reject({ status: 403, msg: 'No session found' }) : resp[0].user_id)
      .then(id => knex('users').where({ id }))
      .then(resp => resp[0]);
  }

  function userById(id) {
    return knex('users').where({ id }).then(resp => (resp[0]));
  }

  function loggedIn(req) {
    return userForSession(req)
      .then(_ => true)
      .catch(_ => false);
  }

  //formats user as json. loggedIn parameter decides if users name is shown in the json
  function formatUser(user, loggedIn) {
    const formattedUser = {};
    formattedUser.id = user.id;
    const userData = user.data;
    formattedUser.name = loggedIn ? (userData.name || '') : 'Tradenomi';
    formattedUser.description = userData.description || '';
    formattedUser.title = userData.title || 'Ei titteliä';
    formattedUser.domains = []; // only get these when getting detailed profile
    formattedUser.positions = []; // only get these when getting detailed profile
    formattedUser.location = userData.location || "";
    formattedUser.profile_creation_consented = userData.profile_creation_consented || false;
    formattedUser.cropped_picture = loggedIn ? (userData.cropped_picture || '') : '';
    formattedUser.special_skills = userData.special_skills || [];
    formattedUser.education = userData.education || [];

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

  function formatAd(databaseAd, loggedIn) {
    return Promise.all([
      knex('answers').where({ad_id: databaseAd.id})
        .then(answers => Promise.all(answers.map(databaseAnswer => formatAnswer(databaseAnswer, loggedIn)))),
      knex('users').where({id: databaseAd.user_id}).then(rows => rows[0])
    ]).then(function ([answers, askingUser]) {
      const ad = {};
      ad.id = databaseAd.id;
      ad.heading = databaseAd.data.heading || '';
      ad.content = databaseAd.data.content || '';
      ad.domain = databaseAd.data.domain;
      ad.position = databaseAd.data.position;
      ad.location = databaseAd.data.location;
      ad.created_by = formatUser(askingUser, loggedIn);
      ad.created_at = databaseAd.created_at;
      ad.answers = loggedIn ? answers : answers.length;
      return ad;
    })
  }


  function formatAnswer(databaseAnswer, loggedIn) {
    return knex('users').where({ id: databaseAnswer.user_id })
      .then(rows => rows[0])
      .then(function(user) {
        const answer = {};
        answer.created_by = formatUser(user, loggedIn);
        answer.content = databaseAnswer.data.content || '';
        answer.id = databaseAnswer.id;
        answer.created_at = databaseAnswer.created_at;
        return answer;
      })
  }

  function formatSettings(settingsIn) {
    const settings = {};
    const dbSettings = settingsIn || {};
    const trueFallback = value => value === undefined ? true : value;
    settings.emails_for_answers = trueFallback(dbSettings.emails_for_answers);
    settings.emails_for_businesscards = trueFallback(dbSettings.emails_for_businesscards);
    settings.emails_for_new_ads = trueFallback(dbSettings.emails_for_new_ads);
    settings.email_address = dbSettings.email_address || '';
    return settings;
  }

  function logValue(tag, value) {
    if (arguments.length === 1) {
      value = tag;
      tag = 'LOG VALUE';
    }
    return console.log(tag, value) || value;
  }

  function patchSkillsToUser(user, skills) {
    user.domains = skills
      .filter(s => s.type === 'domain')
      .map(s => ({ heading: s.heading, skill_level: s.level }));

    user.positions = skills
      .filter(s => s.type === 'position')
      .map(s => ({ heading: s.heading, skill_level: s.level }));
  }

  return  {
    userForSession,
    userById,
    formatUser,
    formatBusinessCard,
    formatAd,
    formatAnswer,
    formatSettings,
    loggedIn,
    logValue,
    patchSkillsToUser
  };
}
