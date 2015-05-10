
exports.up = (knex, Promise) ->
	knex.schema.createTable 'programs_users', (t) ->
		t.increments().primary().index()
		t.integer('user_id').index()
		t.integer('program_id').index()
		t.timestamps()
		

exports.down = (knex, Promise) ->
	knex.schema.dropTable('programs_users')