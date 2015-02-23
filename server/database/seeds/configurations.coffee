###
    t.string("title").notNull()
    t.string("type").notNull()
    t.text("description")
    t.float("lat").notNull()
    t.float("lng").notNull()
###

exports.seed = (knex, Promise) ->
  knex('configurations').insert(
  	settings: {
      requestLimit: 500
      transactionLimit: 100
    }
  )
