// Update with your config settings.

module.exports = {

  development: {
    client: 'postgresql',
    connection: `postgres://${process.env.db_user}:${process.env.db_password}@${process.env.db_host}/tradenomiitti`,
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
    connection: `postgres://${process.env.db_user}:${process.env.db_password}@${process.env.db_host}/tradenomiitti-test`,
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
    connection: `postgres://${process.env.db_user}:${process.env.db_password}@${process.env.db_host}/mib_prod`,
    pool: {
      min: 2,
      max: 10,
    },
    migrations: {
      tableName: 'knex_migrations',
    },
  },
};
