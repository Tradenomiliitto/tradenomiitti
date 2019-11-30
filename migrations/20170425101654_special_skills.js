
exports.up = function(knex) {
  return knex.schema.createTable('special_skills', function (table) {
    table.increments('id');
    table.string('category');
    table.string('title').unique();
  }).then(() => {
    const skills = {
      'Ohjelmointikielet': [
        'Java ',
        'JavaScript',
        'HTML',
        'C',
        'C++',
        'C#',
        'Qt',
        'Objective-C',
        'PHP',
        'Python',
        'Ruby',
        'Ruby on Rails',
        'Scala',
        'Clojure',
        'HTML5',
        'Flash',
        'Silverlight',
        'R',
        'Go',
        'Swift',
        'Arduino',
        'Assembly',
        'Matlab',
        'Perl',
        'Visual Basic',
        'Shell',
        'Cuda',
        'Lua',
        'Processing',
        'SQL',
        'Haskell',
        'Rust',
        'Fortran',
        'Delphi',
        'D',
        'LabView',
        'VHDL',
        'Lisp',
        'Julia',
        'Ladder Logic',
        'Erlang',
        'Verilog',
        'Prolog',
        'SAS',
        'Ada',
        'Cobol',
        'ABAP',
        'Scheme',
        'J',
        'TCL',
        'Ocaml',
        'Forth',
        'Actionscript'
      ],
      'Kielet': [
        'Suomi',
        'Ruotsi',
        'Englanti',
        'Saksa',
        'Venäjä',
        'Italia',
        'Espanja',
        'Ranska',
        'Eesti',
        'Tanska',
        'Norja',
        'Kiina',
        'Japani',
        'Viittomakieli'
      ],
      'Ohjelmat & sovellukset': [
        'Microsoft Office',
        'Microsoft Excel',
        'Microsoft Word',
        'Microsoft PowerPoint',
        'Microsoft Sharepoint',
        'Prezi',
        'ePressi',
        'JIRA',
        'Postiviidakko',
        'Asteri',
        'eTasku',
        'Maestro',
        'Opus Capita',
        'Tikon',
        'Basware',
        'Fivaldi',
        'NetBaron',
        'ProCountor',
        'Western',
        'Econet',
        'Heeros',
        'Netvisor',
        'Readsoft',
        'EmCe',
        'Lemonsoft',
        'Nova',
        'Talgraf',
        'Visma',
        'Comms Client Pro',
        'Effica',
        'Opera',
        'Njorf',
        'Contactor',
        'SaaS',
        'Recrur',
        'Heimo HR',
        'ELBITHR',
        'Solaforce',
        'TyövuoroVelho',
        'Personec W',
        'Mepco HRM',
        'Tiima',
        'SAP',
        'Netvisor HRM',
        'Aditro',
        'Google AdWords',
        'Google analytics',
        'Abode InDesgin',
        'Adobe Illustrator',
        'Twitter',
        'Facebook',
        'Instagram',
        'Snapchat',
        'Slideshare',
        'LinkedIn',
        'Facebook Display',
        'Adobe Creative Cloud',
        'Webropol',
        'SPSS',
        'Digium',
        'SurveyPal',
        'Orbis',
        'MATLAB'
      ],
      'Julkaisualustat': [
        'Liferay',
        'InfoWeb',
        'Wordpress',
        'Processwire',
        'Drupal',
        'Kotisivukone',
        'Open Atrium',
        'TotalDynamic',
        'Blogger',
        'Typepad',
        'Posterous',
        'Tumblr',
        'Movable Type',
        'Expression Engine',
        'Joomla',
        'Drupal Commerce',
        'WooCommerce',
        'EPiServer',
        'EPiServer Commerce',
        'SharePoint',
        'Sitecore',
        'eZ Publish',
        'Sitefinity',
        'WebCenter Suite',
        'Experience Manager',
        'SDL Tridion',
        'Concrete5',
        'SilverStripe',
        'Umbraco',
        'Typo3',
        'Plone',
        'Vizrt Online Suite',
        'Sivuviidakko',
        'Crasman Stage',
        'Stato',
        'Prime',
        'Ambientia Content Manager',
        'Directo',
        'NetCommunity',
        'Shopify',
        'Magento',
        'Magento Enterprise',
        'BigCommerce',
        'Volusion',
        'Yahoo Store',
        'Oracle Commerce',
        'Demandware',
        'osCommerce',
        'ePages',
        'Vilkas',
        'OpenCart',
        'PrestaShop',
        'VirtueMart',
        'Zen Cart',
        'MyCashflow'
      ],
      'Ammattillinen osaaminen': [
        'Palvelumuotoilu',
        'Sosiaalinen media',
        'Johtaminen',
        'Esimies',
        'Projektinhallinta',
        'Markkinatutkimus',
        'Tapahtumamarkkinointi',
        'Tapahtumien järjestäminen',
        'Verkostoituminen',
        'Markkinointistrategia',
        'Strateginen johtaminen',
        'Asiakkuuksien johtaminen',
        'HR',
        'Esiintymistaidot',
        'Myynti',
        'Yrittäjyys',
        'Bloggaus',
        'Vloggaus',
        'Digitalisaatio',
        'Tutkimus ',
        'Datan analysointi',
        'Yrityskehitys',
        'Web design',
        'CRM',
        'Kvalitatiivinen tutkimus',
        'Kvantitatiivinen tutkimus',
        'UI',
        'UX',
        'Back-end',
        'Front-end',
        'Full-stack',
        'Viestintä',
        'Markkinointi',
        'Mainonta',
        'Markkinointiviestintä',
        'Viestintästrategia',
        'Rahoitus',
        'Tuoteomistajuus',
        'Ryhmätyö',
        'Brand management',
        'Business intelligence',
        'Budjetointi',
        'Neuvottelu',
        'Suoramarkkinointi',
        'Videotuotanto',
        'Hakukoneoptimointi',
        'SEO',
        'SEM'
      ],
      'Yleiset': [
        'Politiikka ',
        'Yhteiskunta',
        'Hyvinvointi',
        'Terveys',
        'Koulutus',
        'Kulttuuri',
        'Taide',
        'Tekniikka',
        'Teollisuus',
        'Talous',
        'Tiede',
        'Tasa-arvo',
        'Työelämä',
        'Lapset ja Nuoret',
        'Luonto',
        'Matkailu',
        'Urheilu',
        'Muoti',
        'Ruoka'
      ]
    };
    const skillObjectLists = Object.keys(skills).map(key => {
      return skills[key].map(title => ({ category: key, title }))
    })

    const skillObjects = [].concat.apply([], skillObjectLists);
    return knex('special_skills').insert(skillObjects);
  })
};

exports.down = function(knex) {
  return knex.schema.dropTable('special_skills');
};
