
exports.up = (knex, Promise) ->
	knex.schema.createTable 'meals_programs', (t) ->
		t.increments().primary().index()
		t.integer('program_id').index()
		t.integer('meal_id').index()
		t.timestamps()
		

exports.down = (knex, Promise) ->
	knex.schema.dropTable('meals_programs')