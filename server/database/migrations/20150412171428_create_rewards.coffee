
exports.up = (knex, Promise) ->
	knex.schema.createTable 'rewards', (t) ->
		t.increments().primary().index()
		t.integer('program_id').index()
		t.integer('reward_program_id').index()
		t.decimal('amount')
		t.integer('user_id').index()
		
		t.timestamps()


exports.down = (knex, Promise) ->
	knex.schema.dropTable('rewards')
