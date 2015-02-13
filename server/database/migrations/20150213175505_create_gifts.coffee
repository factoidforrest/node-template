
exports.up = (knex, Promise) ->
	knex.schema.createTable 'gifts', (t) ->
	  t.increments().primary().index()
	  t.integer('card_id').notNull().index()
	  t.float('balance')
	  t.string('status').defaultTo('pending')
	  t.integer('from_id').notNull().index()
	  t.string('to_email').notNull().index()
	  t.timestamps()

exports.down = (knex, Promise) ->
	knex.schema.dropTable('gifts')
  