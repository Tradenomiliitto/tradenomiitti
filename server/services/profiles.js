module.exports = function initialize(params) {
  const knex = params.knex;
  const util = params.util;
  const emails = params.emails;

  function listProfiles(loggedIn, limit, offset, filters = {}, order) {
    let query = knex('users').where({}).select('users.*');
    if (limit !== undefined) query = query.limit(limit);
    if (offset !== undefined) query = query.offset(offset);
    if (filters.domain !== undefined) {
      query = query.whereExists(function () {
        this.select('user_id')
          .from('skills')
          .whereRaw('users.id = skills.user_id and heading = ? and type = ?',
                    [filters.domain, 'domain'])
      });
    }
    if (filters.position !== undefined) {
      query = query.whereExists(function () {
        this.select('user_id')
          .from('skills')
          .whereRaw('users.id = skills.user_id and heading = ? and type = ?',
                    [filters.position, 'position'])
      });
    }
    if (filters.location !== undefined) {
      query = query.whereRaw("users.data->>'location' = ?", [ filters.location ])
    }

    if (filters.special_skill !== undefined) {
      query = query.whereExists(function () {
        this.select('user_id')
          .from('user_special_skills')
          .whereRaw('users.id = user_special_skills.user_id and heading = ?',
                    [filters.special_skill])
      });
    }

    if (filters.institute !== undefined) {
      query = query.whereExists(function () {
        this.select('user_id')
          .from('user_educations')
          .whereRaw("users.id = user_educations.user_id and data->>'institute' = ?",
                    [filters.institute])
      });
    }

    if (filters.specialization !== undefined) {
      query = query.whereExists(function () {
        this.select('user_id')
          .from('user_educations')
          .whereRaw("users.id = user_educations.user_id and data->>'specialization' = ?",
                    [filters.specialization])
      });
    }

    if (order === undefined || order === 'recent') {
      query = query
        .leftOuterJoin('ads', 'users.id', 'ads.user_id')
        .leftOuterJoin('answers', 'users.id', 'answers.user_id')
        .groupBy('users.id')
        .orderByRaw('greatest(max(ads.created_at), max(answers.created_at), users.modified_at) desc nulls last')
    }

    if (order === "alphaDesc") {
      query = query.orderByRaw("lower(users.data->>'name') desc")
    }

    if (order === "alphaAsc") {
      query = query.orderByRaw("lower(users.data->>'name') asc")
    }

    return query
      .then(resp => {
        return resp.map(user => util.formatUser(user, loggedIn));
      })
  }

  function profileSkills(user_id) {
    return knex('skills').where({ user_id });
  }

  function profileEducations(user_id) {
    return knex('user_educations').where({ user_id }).then(rows => rows.map(row => row.data));
  }

  function profileSpecialSkills(user_id) {
    return knex('user_special_skills').where({ user_id }).then(rows => rows.map(row => row.heading));
  }


  function addContact(loggedInUser, toUserId, introductionText) {
    if (typeof introductionText !== 'string' || introductionText.length < 10) {
      return Promise.reject({ status: 400, msg: 'Introduction text is mandatory'});
    }

    if (loggedInUser.id == toUserId) {
      return Promise.reject({ status: 400, msg: 'User cannot add contact to himself' });
    }

    const businessCard = util.formatBusinessCard(loggedInUser.data.business_card);
    if(!businessCard) {
      return Promise.reject('User has no business card');
    }
    if(businessCard.phone.length === 0 && businessCard.email.length === 0) {
      return Promise.reject('User is missing details from business card');
    }
    return knex('contacts').where({ from_user: loggedInUser.id, to_user: toUserId })
      .then(resp => {
        if (resp.length == 0) {
          return knex('contacts').insert({
            from_user: loggedInUser.id,
            to_user: toUserId,
            intro_text: introductionText
          }, 'id')
          .then((data) => knex('events').insert({type: 'add_contact', data: {contact_id: data[0]}}))
          .then(_ => util.userById(toUserId))
          .then(receiver => {
            emails.sendNotificationForContact(receiver, loggedInUser, introductionText);
          })
        }
        else {
          return Promise.reject("User has already given their business card to this user");
        }
      })
  }

  function listContacts(loggedInUser) {
    return knex('contacts').where('to_user', loggedInUser.id).then(rows => {
      const promises =
            rows.map(row => util.userById(row.from_user).then(fromUser => ({
              user: util.formatUser(fromUser, true),
              business_card: util.formatBusinessCard(fromUser.data.business_card || {}),
              intro_text: row.intro_text || '',
              created_at: row.created_at
            })))
      return Promise.all(promises);
    });
  }

  function contactExists(from, to) {
    return knex('contacts').where({
      from_user: from.id,
      to_user: to.id
    }).then(resp => resp.length > 0)
  }

  return {
    listProfiles,
    profileSkills,
    profileEducations,
    profileSpecialSkills,
    addContact,
    listContacts,
    contactExists
  }
};
