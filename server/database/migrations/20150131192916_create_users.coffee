
exports.up = (knex, Promise) ->
	knex.schema.createTable 'users', (t) ->
	  t.increments().primary().index()
	  t.string('email').notNull().unique().index()
	  t.string('new_email').unique()
	  t.string('password')
	  t.string('confirmation_token').index()
	  t.string('first_name')
	  t.string('last_name')
	  t.boolean('admin')
	  t.boolean('active').notNull().defaultTo(true)
	  t.timestamps()


exports.down = (knex, Promise) ->
	knex.schema.dropTable('users')
  