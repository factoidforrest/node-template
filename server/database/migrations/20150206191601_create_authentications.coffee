exports.up = (knex, Promise) ->
	knex.schema.createTable 'authentications', (t) ->
		t.increments().primary().index()
		t.integer('user_id')#.references('user.id')) < what does this do
		t.string('provider')
		t.string('access_token').index()
		t.string('refresh_token')
		t.string('uid')
		t.dateTime('expires_at')
		t.string('email')
		t.string('name')
		t.timestamps()

exports.down = (knex, Promise) ->
	knex.schema.dropTable('authentications')
	