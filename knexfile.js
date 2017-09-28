// Update with your config settings.

module.exports = {

  development: {
    client: 'postgresql',
    connection: {
      host: process.env.db_host,
      database: process.env.db_name,
      user: process.env.db_user,
      password: process.env.db_password,
    },
    pool: {
      min: 2,
      max: 10,
    },
    migrations: {
      tableName: 'knex_migrations',
    },
  },

  test: {
    client: 'postgresql',
    connection: {
      host: process.env.db_host,
      database: 'tradenomiitti-test',
      user: process.env.db_user,
      password: process.env.db_password,
    },
    pool: {
      min: 2,
      max: 5,
    },
    migration: {
      tableName: 'knex_migrations',
    },
    seeds: {
      directory: 'seeds/test',
    },
  },

  production: {
    client: 'postgresql',
    connection: {
      host: process.env.db_host,
      database: process.env.db_name,
      user: process.env.db_user,
      password: process.env.db_password,
    },
    pool: {
      min: 2,
      max: 10,
    },
    migrations: {
      tableName: 'knex_migrations',
    },
  },
};
