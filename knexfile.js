// Update with your config settings.

module.exports = {

  development: {
    client: 'postgresql',
    connection: `postgres://${process.env.db_user}:${process.env.db_password}@${process.env.db_host}:5432/tradenomiitti`,
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
    connection: `postgres://${process.env.db_user}:${process.env.db_password}@${process.env.db_host}:5432/tradenomiitti-test`,
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
    connection: `postgres://${process.env.db_user}:${process.env.db_password}@${process.env.db_host}:5432/mib_prod`,
    pool: {
      min: 2,
      max: 10,
    },
    migrations: {
      tableName: 'knex_migrations',
    },
  },
};
