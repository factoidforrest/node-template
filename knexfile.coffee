# Update with your config settings.

module.exports =

  development:
    seeds: {
      directory: './server/database/seeds/'
    }
    client: 'postgresql'
    connection:
      database: 'beerme'
      user:     'root'
      password: ''
    migrations:
      tableName: 'knex_migrations'

  test:
    client: 'postgresql'
    connection:
      database: 'beermetest'
      user:     'root'
      password: ''
    migrations:
      tableName: 'knex_migrations'

  production:
    client: 'postgresql'
    seeds: {
      directory: './server/database/seeds/'
    }
    connection: process.env.DATABASE_URL
    pool:
      min: 2
      max: 10
    migrations:
      tableName: 'knex_migrations'
