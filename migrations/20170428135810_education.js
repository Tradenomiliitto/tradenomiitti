
exports.up = function(knex) {
  return knex.schema.createTable('education', function (table) {
    table.increments('id');
    table.enum('type', [ 'institute', 'degree', 'major', 'specialization' ]).notNullable().index();
    table.string('category');
    table.string('title');
    table.unique([ 'title', 'type' ]);
  }).then(() => {
    const institutes = {
      'Ammattikorkeakoulu': [
        'Arcada, Nylands svenska yrkeshögskola',
        'Centria-AMK',
        'Diakonia-ammattikorkeakoulu',
        'Haaga-Helia ammattikorkeakoulu',
        'Humanistinen ammattikorkeakoulu',
        'Hämeen ammattikorkeakoulu',
        'Högskolan på Åland',
        'Jyväskylän ammattikorkeakoulu',
        'Kajaanin ammattikorkeakoulu',
        'Karelia-ammattikorkeakoulu',
        'Lahden ammattikorkeakoulu',
        'Lapin ammattikorkeakoulu (Kemi-Tornion ammattikorkeakoulu & Rovaniemen ammattikorkeakoulu)',
        'Laurea-ammattikorkeakoulu',
        'Metropolia-ammattikorkeakoulu',
        'Oulun seudun ammattikorkeakoulu',
        'Poliisiammattikorkeakoulu',
        'Saimaan ammattikorkeakoulu',
        'Satakunnan ammattikorkeakoulu',
        'Savonia-ammattikorkeakoulu',
        'Seinäjoen ammattikorkeakoulu',
        'Suomen ammattikorkeakoulut',
        'Tampereen ammattikorkeakoulu',
        'Turun ammattikorkeakoulu',
        'Vaasan ammattikorkeakoulu',
        'XAMK Kaakkois-Suomen ammattikorkeakoulu (Mikkelin AMK & Kymenlaakson AMK)',
        'Yrkeshögskolan Novia',
        'Muu ammattikorkeakoulu'
      ],
      'Yliopisto': [
        'Aalto Yliopistot',
        'Helsingin Yliopisto',
        'Itä-Suomen Yliopisto',
        'Jyväskylän Yliopisto',
        'Lapin Yliopisto',
        'Lappeenrannan teknillinen Yliopisto',
        'Maanpuolustuskorkeakoulu',
        'Oulun Yliopisto',
        'Svenska Handelshögskolan',
        'Taideyliopisto',
        'Tampereen teknillinen yliopisto',
        'Tampereen yliopisto',
        'Turun yliopisto',
        'Vaasan yliopisto',
        'Åbo Akademi'
      ],
      'Muut': [
        'Korkeakoulu ulkomailla',
        'Lukio',
        'Ammattikoulu / ammattiopisto',
        'Opisto'
      ]
    };
    const degrees = {
      'Yleiset': [
        'Tradenomi',
        'Tradenomi YAMK (AMK-maisteri)',
        'Kauppatieteiden maisteri',
        'Merkonomi',
        'Ylioppilas',
        'Datanomi',
        'HSO-sihteeri'
      ]
    };
    const majors = {
      'Tradenomiopinnot': [
        'Aviation Business',
        'Bachelor of business administration',
        'Business Information Technology',
        'European business administration',
        'Finanssi- ja talousasiantunija',
        'Hankinta- ja myyntiosaaminen',
        'International business management',
        'International business and logistics',
        'Johdon assistenttityö ja kielet',
        'Kirjasto- ja tietopalvelut',
        'Liiketalous',
        'Liiketoiminnan logistiikka',
        'Mediatuotanto',
        'Myyntityö',
        'Yrittäjyys',
        'Tietojenkäsittely',
        'Turvallisuusala',
        'Wellness-liiketoiminta',
        'Liiketoiminnan kehittäminen',
        'Viestintä ja markkinointi',
        'Digitaaliset palvelut / digital services',
        'Information system management',
        'Palveluliiketoiminta ja palvelumuotoilu / Service design',
        'Educational leadership',
        'Hankintatoimi ',
        'Health business management ',
        'Hyvinvointiteknologia ',
        'Projektijohtaminen',
        'Päätöksenteon ilmiöt johtamisessa, kehittämisessä ja asiakastyössä',
        'Sähköinen asiointi ja arkistointi',
        'Tietojärjestelmäosaaminen',
        'Turvallisuusjohtaminen',
        'Tutkimusryhmäopinnot',
        'Ammatillinen opettajakorkeakoulu'
      ],
      'Yliopistotutkinnot': [
        'Kasvatustieteet',
        'Kauppatieteet',
        'Lääketiede',
        'Oikeustieteet',
        'Humanistiset tieteet',
        'Eläinlääketiede',
        'Luonnontieteet',
        'Teologiset tieteet',
        'Valtiotiteteet',
        'Yhteiskuntatieteet',
        'Ympäristötieteet',
        'Maataloustieteet',
        'Metsätaloustieteet',
        'Biotieteet',
        'Hammaslääketiede',
        'Liikuntatiede',
        'Psykologia',
        'Sotilasala',
        'Taiteiden ala',
        'Terveystieteet'
      ],
      'Muut opetusalat': [
        'Humanistinen ja kasvatusala',
        'Kulttuuriala',
        'Luonnontieteiden ala',
        'Luonnonvara- ja ympäristöala',
        'Matkailu-, ravitsemis- ja talousala',
        'Sosiaali-, terveys- ja liikunta-ala',
        'Tekniikan ja liikenteen ala',
        'Turvallisuusala (muu)',
        'Yhteiskuntatieteiden, liiketalouden ja hallinnon ala',
        'Lukion oppimäärä'
      ]
    };
    const specializations = {
      'Yleiset': [
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
        'Asiakaspalvelu ja asiakkuuksien johtaminen'
      ]
    };

    function toObjectLists(object, type) {
      return Object.keys(object).map(key => {
        return object[key].map(title => ({ category: key, title, type }));
      });
    }

    const listOfListsOfListsOfObjects = [
      toObjectLists(institutes, 'institute'),
      toObjectLists(degrees, 'degree'),
      toObjectLists(majors, 'major'),
      toObjectLists(specializations, 'specialization')
    ]

    const listOfListsOfObjects = [].concat.apply([], listOfListsOfListsOfObjects);

    const insertObjects = [].concat.apply([], listOfListsOfObjects);
    return knex('education').insert(insertObjects);
  });
};

exports.down = function(knex) {
  return knex.schema.dropTable('education');
};
