
exports.up = (knex, Promise) ->
	knex.schema.createTable 'invitations', (t) ->
		t.increments().primary().index()
		t.integer('sender_id').index()
		t.string('email').index()
		t.string('status').defaultTo('pending')
		t.timestamps()

exports.down = (knex, Promise) ->
	knex.schema.dropTable('invitations')
	