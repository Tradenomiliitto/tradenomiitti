
exports.seed = function(knex, Promise) {
  // Deletes ALL existing entries
  return knex('users').del()
    .then(function () {
      return Promise.all([
        // Inserts seed entries
        knex('users').insert({first_name: "Pekka", description: "Keski-ikäinen tradenomi Uudeltamaalta."}),
        knex('users').insert({first_name: "Sirpa", description: "IT-alalla työskentelevä tradenomi Varsinais-Suomesta."})
      ]);
    });
};
