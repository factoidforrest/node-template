
exports.up = (knex, Promise) ->
	knex.schema.createTable 'cards', (t) ->
	  t.increments().primary().index()
	  t.string('number').notNull().unique().index()
	  t.float('init_value')
	  t.float('remaining_value')
	  t.float('balance')
	  t.string('gift_status')
	  t.integer('user_id').notNull().index()
	  t.timestamps()

exports.down = (knex, Promise) ->
	knex.schema.dropTable('cards')
  