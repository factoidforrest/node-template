###
    t.string("title").notNull()
    t.string("type").notNull()
    t.text("description")
    t.float("lat").notNull()
    t.float("lng").notNull()
###

exports.seed = (knex, Promise) ->
  knex('locations').insert(
  	{
  		title: 'test point'
  		type: 'store'
  		description: 'An example point used for testing purposes'
  		lat:40.7127
  		lng: -74.0059
  		created_at: knex.raw('now()')
  		updated_at: knex.raw('now()')
  	}
  )
