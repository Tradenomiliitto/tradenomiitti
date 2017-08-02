// Update with your config settings.

module.exports = {

  development: {
    client: 'postgresql',
    connection: {
      database: 'tradenomiitti',
      user:     process.env.db_user,
      password: process.env.db_password
    },
    pool: {
      min: 2,
      max: 10
    },
    migrations: {
      tableName: 'knex_migrations'
    },
    seeds: {
      directory: 'seeds/development',
    },
  },

  test: {
    client: 'postgresql',
    connection: {
      database: 'tradenomiitti-test',
      user: process.env.db_user,
      password: process.env.db_password
    },
    pool: {
      min: 2,
      max: 5
    },
    migration: {
      tableName: 'knex_migrations'
    }
  },

  production: {
    client: 'postgresql',
    connection: {
      database: 'tradenomiitti',
      user:     process.env.db_user,
      password: process.env.db_password
    },
    pool: {
      min: 2,
      max: 10
    },
    migrations: {
      tableName: 'knex_migrations'
    }
  }

};
