
exports.up = (knex, Promise) ->
	###
	knex.schema.createTable 'rewards', (t) ->
		t.increments().primary().index()b
		t.string 'description'
		#this is the mauid
		t.string('client_id').index()
		t.timestamps()
	###

exports.down = (knex, Promise) ->
	#knex.schema.dropTable('rewards')
