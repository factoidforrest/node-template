
exports.up = (knex, Promise) ->
  knex.schema.createTable 'tokens', (t) ->
	  t.increments().primary().index()
	  t.integer('tokenable_id')#.references('books.id')
	  t.string('tokenable_type')
	  t.string('key').index()
	  t.string('type').index() #not sure this index is useful since this will be chained, should maybe create a multi index off of key and type
	  t.timestamps()


exports.down = (knex, Promise) ->
	knex.schema.dropTable('tokens')
  