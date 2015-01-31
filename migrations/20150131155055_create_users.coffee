
exports.up = (knex, Promise) ->
  return knex.schema.createTable "users", (t) ->
    t.increments().primary()
    t.string("title").notNull()
    t.string("type").notNull()
    t.text("description")
    t.float("lat").notNull()
    t.float("lng").notNull()
    #confirmed this two field index works using pgadmin
    t.index(['lat', 'lng'])
    t.timestamps()
    return



exports.down = (knex, Promise) ->
  knex.schema.dropTable "users"