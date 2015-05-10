
exports.up = (knex, Promise) ->
 knex.schema.createTable 'reward_programs', (t) ->
		t.increments().primary().index()
		t.string('name')
		t.string('description')
		t.string('type')
		t.decimal('threshold')
		t.decimal('reward')
		t.decimal('percentage')
		t.timestamps()
		

exports.down = (knex, Promise) ->
	knex.schema.dropTable('reward_programs')