
exports.up = (knex, Promise) ->
	knex.schema.createTable 'users', (t) ->
	  t.increments().primary().index()
	  t.string('email').notNull().unique().index()
	  t.string('password')
	  t.string('confirmation_token').index()
	  t.string('firstname')
	  t.string('lastname')
	  t.boolean('admin')
	  t.timestamps()


exports.down = (knex, Promise) ->
	knex.schema.dropTable('users')
  