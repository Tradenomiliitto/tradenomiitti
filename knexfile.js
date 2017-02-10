// Update with your config settings.

module.exports = {

  local: {
    client: 'sqlite3',
    connection: {
      filename: './dev.sqlite3'
    }
  },

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
