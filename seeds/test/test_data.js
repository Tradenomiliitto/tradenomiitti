const aino_data = {
  name: 'Aino',
  business_card: {
    name: 'Aino',
    phone: '123456789',
  },
  description: 'Meow all night having their mate disturbing sleeping humans put toy mouse in food bowl run out of litter box at full speed intrigued by the shower and sometimes switches in french and say "miaou" just because well why not but stares at human while pushing stuff off a table.',
  location: 'Helsinki',
  work_status: 'working',
  contribution: 'Haluan opettaa tennistä',
  children: [{ year: 2002, month: 4 }],
};

const sinituuli_data = {
  name: 'Sinituuli',
  business_card: {
    name: 'Sinituuli',
    phone: '123456789',
  },
  description: 'I guess it\'s better to be lucky than good. Your shields were failing, sir. Besides, you look good in a dress.',
  work_status: 'working',
  contribution: '',
  children: [{ year: 2017, month: 6 }, { year: 2015, month: 3 }, { year: 2014, month: 1 }],
};

const member_data = {
  Etunimi: '',
  Sukunimi: '',
  Paikallisjaosto: '',
  Sähköpostiosoite: '',
  Matkapuhelinnumero: '',
  Lähiosoite: '',
  Postinumero: '',
  Postitoimipaikka: ''
};

exports.seed = function(knex, Promise) {
  // Deletes ALL existing entries
  return knex('users').del()
    .then(() =>
      knex('users').insert({
        id: 1,
        remote_id: -1,
        settings: { isAdmin: true, email_address: 'test@test.com' },
        data: aino_data,
        member_data,
        pw_hash: '$2a$10$v0TXETGJwbBq73NZyWO4qOsw19P1Js3VXFosacTxb72QU3B/RP.sW',
      }))
    .then(() =>
      knex('users').insert({
        id: 2,
        remote_id: -2,
        settings: { email_address: 'test2@test.com' },
        data: sinituuli_data,
        member_data,
        pw_hash: '$2a$10$v0TXETGJwbBq73NZyWO4qOsw19P1Js3VXFosacTxb72QU3B/RP.sW',
      }))
    .then(() =>
      knex('sessions').insert([
        { id: '00000000-0000-0000-0000-000000000001', user_id: 1 },
        { id: '00000000-0000-0000-0000-000000000002', user_id: 2 },
      ]))
    .then(() =>
      knex('ads').insert({
        data: { heading: 'Chew foot', content: 'Chew foot cough hairball on conveniently placed pants so under the bed. Have secret plans warm up laptop with butt lick butt fart rainbows until owner yells pee in litter box hiss at cats so find something else more interesting. Walk on car leaving trail of paw prints on hood and windshield eats owners hair then claws head.' },
        user_id: 1,
        created_at: new Date(2017, 4, 1),
      }).returning('id'))
    .then(id =>
      knex('answers').insert({
        data: { content: 'Fate. It protects fools, little children, and ships named "Enterprise." Shields up! Rrrrred alert! What? We\'re not at all alike! Mr. Worf, you sound like a man who\'s asking his friend if he can start dating his sister. Could someone survive inside a transporter buffer for 75 years? Fate protects fools, little children and ships named Enterprise.' },
        user_id: 2,
        ad_id: parseInt(id, 10),
        created_at: new Date(2017, 4, 5),
      }))
    .then(() =>
      knex('ads').insert({
        data: { heading: 'How to eat gagh', content: 'Yesterday I did not know how to eat gagh. I can\'t. As much as I care about you, my first duty is to the ship. I am your worst nightmare!' },
        user_id: 1,
        created_at: new Date(2017, 4, 3),
      }))
    .then(() =>
      knex('ads').insert({
        data: { heading: 'Worst nightmare', content: 'Use lap as chair vommit food and eat it again meowwww. Bathe private parts with tongue then lick owner\'s face cats secretly make all the worlds muffins. Chew foot chase ball of string scream for no reason at 4 am immediately regret falling into bathtub i cry and cry and cry unless you pet me, and then maybe i cry just for fun put toy mouse in food bowl run out of litter box at full speed and catch mouse and gave it as a present. ' },
        user_id: 1,
        created_at: new Date(2017, 4, 2),
      }).returning('id'))
    .then(id =>
      knex('answers').insert({
        data: { content: 'What? We\'re not at all alike! Mr. Worf, you do remember how to fire phasers?' },
        user_id: 2,
        ad_id: parseInt(id, 10),
        created_at: new Date(2017, 4, 4),
      }))
    .then(() =>
      knex('events').del()
    )
    .then(() => knex('remote_user_register').insert({
      remote_id: -1,
      settings: { isAdmin: true, email_address: 'test@test.com' },
    }))
    .then(() => knex('remote_user_register').insert({
      remote_id: -2,
      settings: { email_address: 'test2@test.com' },
    }));
};
