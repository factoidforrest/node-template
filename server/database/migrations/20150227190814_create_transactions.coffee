
exports.up = (knex, Promise) ->
	knex.schema.createTable 'transactions', (t) ->
		t.increments().primary().index()
		t.integer('user_id').index()
		t.integer('card_id').index()
		t.integer('meal_id').index()
		t.string('card_number').index()
		t.float('amount')
		t.string('type')
		t.json('data')
		t.string('status').defaultTo('pending')
		t.timestamps()

exports.down = (knex, Promise) ->
	knex.schema.dropTable('transactions')
	