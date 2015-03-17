
exports.up = (knex, Promise) ->
	knex.schema.createTable 'meals', (t) ->
	  t.increments().primary().index()
	  t.integer('program_id').index()
	  t.float('balance')
	  t.float('price')
	  t.json('items')
	  t.string('key').index()
	  t.string('status').defaultTo('pending')
	  t.timestamps()

exports.down = (knex, Promise) ->
	knex.schema.dropTable('meals')
  