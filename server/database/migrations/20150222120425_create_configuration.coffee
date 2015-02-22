
exports.up = (knex, Promise) ->
	knex.schema.createTable 'configurations', (t) ->
		t.increments().primary().index()
		t.json('data').defaultTo()
		t.timestamps()

exports.down = (knex, Promise) ->
	knex.schema.dropTable('configurations')
	