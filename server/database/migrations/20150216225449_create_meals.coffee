
exports.up = (knex, Promise) ->
	knex.schema.createTable 'meals', (t) ->
	  t.increments().primary().index()
	  t.integer('restaurant_id').index()
	  t.float('balance')
	  t.json('items')
	  t.string('key').index()
	  t.string('status').defaultTo('unpaid')
	  t.timestamps()

exports.down = (knex, Promise) ->
	knex.schema.dropTable('meals')
  