# Update with your config settings.

module.exports =

  development:
    seeds: {
      directory: './server/database/seeds/'
    }
    client: 'postgresql'
    connection:
      database: 'mobilegiftcarddev'
      user:     'root'
      password: ''
    migrations:
      tableName: 'knex_migrations'
      directory: __dirname + "/server/database/migrations"

  test:
    client: 'postgresql'
    connection:
      database: 'mobilegiftcardtest'
      user:     'root'
      password: ''
    migrations:
      tableName: 'knex_migrations'
      directory: __dirname + "/server/database/migrations"



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
      directory: __dirname + "/server/database/migrations"
