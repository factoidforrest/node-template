require '../../../server'
async = require 'async'

###
	  t.string('number').notNull().unique().index()
	  t.float('init_value')
	  t.float('remaining_value')
	  t.float('balance')
	  t.string('gift_status')
	  t.integer('user_id').index()
	  t.string('status')
	  t.string('client_id')
	  t.integer('program_id')
	  t.string('serial')
###

Program.fetchAll().then (programs) ->
	program = programs.first()
	createCard = (n, cb) ->
		TCC.createCard(10, program.get('client_id')).then (data) ->

			console.log('got tcc data ', data)
			Card.forge({
				number: data.card_number
				status: data.status
				serial: data.serial
				balance: data.balance
				program_id: program.get('id')
			}).save().then (card) ->

				cb(null, card.get('number'))

	async.times 100, createCard, (err, cardNumbers) ->
		console.log('async err: ', err)
		console.log('created test cards: ', cardNumbers)
		process.exit()