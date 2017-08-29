
exports.up = function(knex, Promise) {
  return knex.schema.createTable('education', function (table) {
    table.increments('id');
    table.enum('type', ['degree', 'specialization']).notNullable().index();
    table.string('category');
    table.string('title');
    table.unique(['title', 'type']);
  }).then(() => {
    const degrees = {
      Yleiset: [
        'DI',
        'ETK',
        'ETL',
        'ETM',
        'ETT',
        'ELK',
        'ELL',
        'ELT',
        'FaL',
        'FaT',
        'FL',
        'FM',
        'FT',
        'HTK',
        'HK',
        'HTL',
        'HM',
        'HTT',
        'HT',
        'HLK',
        'HLL',
        'HLT',
        'HuK',
        'KK',
        'KL',
        'KM',
        'KY',
        'KTK',
        'KTL',
        'KTM',
        'KTT',
        'LitL',
        'LitM',
        'LitT',
        'LK',
        'LL',
        'LT',
        'LuK',
        'MMK',
        'MML',
        'MMM',
        'MMT',
        'ON',
        'OTL',
        'OTM',
        'OTT',
        'PsK',
        'PsL',
        'PsM',
        'PsT',
        'SK',
        'SM',
        'ST',
        'TkK',
        'TkL',
        'TkT',
        'TK',
        'TL',
        'TM',
        'TT',
        'TtK',
        'TtL',
        'TtM',
        'TtT',
        'VTK',
        'VTL',
        'VTM',
        'VTT',
        'YET',
        'YTK',
        'YTL',
        'YTM',
        'YTT',
        'KuK',
        'KuM',
        'KuT',
        'MuK',
        'MuL',
        'MuM',
        'MuT',
        'TaK',
        'TaM',
        'TaT',
        'TeK',
        'TeL',
        'TeM',
        'TeT',
      ],
    };
    const specializations = {
      Yleiset: [
        'Graafinen suunnittelu',
        'Palveluliiketoiminta ja palvelumuotoilu',
        'Brändiosaaja',
        'Datacenter-ratkaisut',
        'Sähköinen liiketoiminta ja digitaaliset palvelut',
        'Esimiestyö',
        'Johtaminen',
        'HR & henkilöstöjohtaminen',
        'Finanssiala',
        'Kansainvälinen kauppa / international business',
        'Peliala / game production',
        'Juridiikka, julkishallinto ja hankitatoimi',
        'HTM Tilintarkastaja',
        'Matkailu / tourism',
        'ICT',
        'Yrittäjyys',
        'Liiketoiminnan kehittäminen',
        'Järjestelmähallinta',
        'Kiertotalous',
        'Taloushallinto & laskentatoimi',
        'Logistiikka',
        'Markkinointi, mainonta ja viestintä',
        'Myynti',
        'Ohjelmistotuotanto',
        'Projektijohtaminen',
        'Sovellustuotano',
        'Tietoturva',
        'Tietoverkkopalvelut',
        'Tiimiakatemija, yrittäjyys',
        'Tuotantotalous',
        'Työhyvinvointi',
        'Urheiluliiketoiminta',
        'Web development & web design',
        'Mobiilisovelluskehitys',
        'Rahoitus',
        'Kulttuurituotanto',
        'Kielet',
        'Opettajan koulutus',
        'Opinto-ohjaajan koulutus',
        'Erityisopettajan koulutus',
        'Asiakaspalvelu ja asiakkuuksien johtaminen',
      ],
    };

    function toObjectLists(object, type) {
      return Object.keys(object).map(key => {
        return object[key].map(title => ({ category: key, title, type }));
      });
    }

    const listOfListsOfListsOfObjects = [
      toObjectLists(degrees, 'degree'),
      toObjectLists(specializations, 'specialization')
    ]

    const listOfListsOfObjects = [].concat.apply([], listOfListsOfListsOfObjects);

    const insertObjects = [].concat.apply([], listOfListsOfObjects);
    return knex('education').insert(insertObjects);
  });
};

exports.down = function(knex, Promise) {
  return knex.schema.dropTable('education');
};
