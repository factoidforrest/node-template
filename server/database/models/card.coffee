Promise = require("bluebird")
###
bcrypt = Promise.promisifyAll(require('bcrypt-nodejs'))
crypto = Promise.promisifyAll require 'crypto'
Mail = Promise.promisifyAll require '../../services/mail'
###
crypto = require 'crypto'
moment = require 'moment'
async = require 'async'
Payment = require '../../services/payment'

module.exports = (bookshelf) ->
	global.Card = bookshelf.Model.extend({
		tableName: 'cards'
		hasTimestamps: true
		virtuals: 
			description: () ->
				if @related('program')?	
					return @related('program').get('description')
				else
					return 'Description not available'

			#the maUid defined by TCC


			

		initialize: () ->
			###
			this.on 'saving', (model, attrs, options) ->
				#creating a promise manually like this is considered bad, but using promisification doesn't work so..
				deferred = Promise.pending()
				model.generateToken null, () ->
					logger.info 'token created'
					deferred.fulfill 'token created'
				
				return deferred.promise
			###

		user: ->
			return @belongsTo(User)

		transactions: ->
			return @hasMany(Transaction)

		program: ->
			return @belongsTo(Program)

		#doesn't save, just updates in place
		TCCSync: (done) ->
			console.log('syncing card')
			card = this
			TCC.cardInfo(this).catch( (err) ->
				console.log('sync error with tcc', err)
				if err.name == 'connectionError'
					done({code: 500, name:'connectionError', error:err, message: 'Trouble contacting the card server'})
				else if err.name == 'TCCError'
					done({code: 500, name:'TCCErr', error: err, message: 'Please double check the card number'})
				else 
					done(err)
			).then( (data) ->
				newBalance = Number(data.balance)
				#console.log('read card data from tcc: ', data)
				card.set('balance', newBalance)
				#card.set('status', data.status) Ignore the TCC status, it doesn't void properly
				done(null, card)
			)

		refill: (properties, done) ->
			card = this
			@changeTCCBalance 'add', properties, (err, serial) ->
				return done(err) if err?
				Payment.authorize {amount: properties.amount, nonce: properties.nonce, settle: true},  (paymentErr, authorization) ->
					if paymentErr?
						logger.log 'error', 'error processing payment on refill of card: ', card.attributes, 'with error: ', paymentErr
						console.log('payment error, about to void tcc transaction')
						return TCC.void card, serial, (err) ->
							#not efficient to call tcc again but it happens rarely
							return card.TCCSync (err, syncedCard) ->
								card.save().then (savedCard) ->
									return done(paymentErr)
					card.save().then () ->
						Transaction.forge(
							user_id: card.get('user_id')
							card_id: card.get('id')
							card_number: card.get('number')
							amount: authorization.transaction.amount
							type: 'refill'
							status: authorization.transaction.status
							data: {authorization: authorization.transaction}#, settlement: settlement.transaction}
						).save().then (savedTransaction) ->

							done(null, card)

		posFill: (properties, done) ->
			card = this
			#needs to include location in request? 
			@changeTCCBalance 'add', properties, (err, serial) ->
				return done(err) if err?
				card.save().then () ->
					Transaction.forge(
						card_id: card.get('id')
						card_number: card.get('number')
						amount: properties.amount
						type: 'posFill'
						status: 'success'
						data: {}
					).save().then (savedTransaction) ->

						done(null, card)			

		redeem: (properties, done) ->
			if @balance < properties.amount
				return done({code: 400, name: 'balanceExceeded', message: 'Your card does not have enough value remaining to make this transaction'})
			card = this
			Meal.forge(key: properties.meal_key).fetch(withRelated:['transactions.card', 'programs']).then (meal) ->
				logger.info 'redeeming card on meal: ', meal.attributes
				return done({code: 400, name: 'mealNotFound', message: 'No meal matching that key was found'}) if !meal?
				if meal.related('transactions').where({card_id: card.get('id'), status: 'pending'}).length > 0
					return done({code:400, 'duplicateRedeem', message: 'This card has already been used on this meal.'})
				program = card.related('program')
				if meal.related('programs').where({id:program.get('id')}).length != 1
					return done({code:400, name: 'programErr', message: 'Card cannot be used at this restaurant'})
				if meal.get('status') != 'pending'
					return done({code: 400, name: 'mealClosed', message: 'The meal has already been checked out'}) 
				if meal.get('balance') < properties.amount
					return done({code: 400, name: 'overpaid', message: 'Payed more than the cost of the meal'}) 

				Transaction.forge(
					user_id: properties.user_id || null
					card_number: card.get('number')
					card_id: card.get('id')
					meal_id: meal.get('id')
					amount: properties.amount
					type: 'redeem'
					data: {card_type: 'local'}
				).save().then (transaction) ->
					###
					TCC.redeemCard(card.get('number'), properties.amount).then((tccResponse) ->
						console.log 'got redeemed card: ', tccResponse
						card.set(balance:tccResponse.balance).save().then (savedCard) ->
					###
					properties.location_id = meal.get('location_id')
					card.changeTCCBalance 'subtract', properties, (err) ->
						card.save().then (savedCard) ->
							meal.query().decrement('balance', properties.amount).then () ->
								#update decremented meal from database..not super efficient but it works
								Meal.forge({id:meal.get('id')}).fetch(withRelated: ['transactions.card', 'programs']).then (savedMeal) ->
									done(null, {card: savedCard, meal: savedMeal})


		unredeem: (properties, done) ->
			card = this
			Meal.forge(key: properties.meal_key).fetch().then (meal) ->
				Transaction.forge(meal_id: meal.get('id'), card_id: card.get('id')).fetch().then (transaction) ->
					if transaction.get('status') != 'pending'
						return done({code:400, name: 'transactionState', message:"Failed to cancel the transaction because its status was: " + transaction.get('status')})
					transaction.set('status', 'void')
					card.changeTCCBalance 'add', {amount: transaction.get('amount'), location_id: meal.get('location_id')}, (err) ->
						return err if err?
						card.save().then (savedCard) ->
							transaction.save().then (savedTransaction) ->
								meal.query().increment('balance', transaction.get('amount')).then () ->
									Meal.forge({id:meal.get('id')}).fetch(withRelated: ['transactions.card', 'programs']).then (savedMeal) ->
										done(null, {card: savedCard, meal: savedMeal})




		changeTCCBalance: (action, properties, done) ->
			self = this
			if action == 'add'
				request = TCC.refillCard
			else if action == 'subtract'
				request = TCC.redeemCard
			request(@get('number'), @get('client_id'), properties.location_id, properties.amount).then((data) ->
				self.set({balance: data.balance, status: data.status})
				done(null, data.serial)
			).catch (err) ->
				logger.log('error','error with tcc', err, ' changing balance of card: ', self.attributes)
				if err.name == 'connectionError'
					done({code: 500, name:'connectionError', error:err, message: 'Trouble contacting the card server'})
				else if err.name == 'TCCError'
					done({code: 500, name:'TCCErr', error: err, message: 'Something went wrong.  Please double check the card number'})
				else 
					done(err)


		void: (done) ->
			self = this
			TCC.void self, self.get('serial'), (err) ->
				logger.log 'voided card: ', self.attributes, 'with tcc error: ', err
				#we ignore the tcc error here pretty much because even if the card isn't void at tcc
				#it needs to be void in our system anyway, which is probably good enough since we are
				#the only ones who know the card number
				self.set('status', 'void')
				self.set('balance', 0)
				self.save().then (savedCard) ->
					console.log('card attributes after being voided ', savedCard.attributes)
					done(err)





	},{

		#this also saves the changes to the database, if there were any
		syncGroup : (cards, done) ->
			#this needs to somehow handle when one of the cards throws an error
			console.log('syncing card group:', JSON.stringify(cards))
			async.map cards, syncCard, done
		

		#create
		purchase: (properties, done) ->
			if !properties.balance? or !properties.program_id? or !properties.nonce?
				return done({code: 400, name:'argumentsInvalid', message: 'You must specify a restaurant, amount, and payment method'})
			Card.build properties, (err, card) ->
				if err?
					logger.error('error allocating a new card for purchase at tcc', err)
					return done(err)
				Payment.authorize {amount: properties.balance, nonce: properties.nonce, settle: true},  (paymentErr, authorization) ->
					if paymentErr?
						console.log('payment error, about to void card')
						return card.void (err) ->
							logger.error err if err?
							return done(paymentErr)
					console.log('authorized payment ', authorization)
					Transaction.forge(
						user_id: properties.user_id
						card_id: card.get('id')
						card_number: card.get('number')
						amount: authorization.transaction.amount
						type: 'purchase'
						status: authorization.transaction.status
						data: {authorization: authorization.transaction}#, settlement: settlement.transaction}
					).save().then (savedTransaction) ->
						console.log('created a transaction')
						logger.info('transaction saved: ', savedTransaction)
						#pretty print to the console
						console.log(savedTransaction)
						done(null, card)

		build: (properties, done) ->
			Program.forge(id: properties.program_id).fetch().then (program) ->
				return done({code:404, name: 'programNotFound', message: 'No program matching that ID was found.'}) if !program?
				card = Card.forge(user_id: properties.user_id, program_id: properties.program_id, client_id: program.get('client_id'))
				TCC.createCard(properties.balance, program.get('client_id')).then((data) ->

					card.set('balance', data.balance)
					card.set('status', data.status)
					card.set('number', data.card_number)
					card.set('serial', data.serial)

					card.save().then (savedCard) ->
						done(null, savedCard)
				).catch (err) ->
					logger.log('error', 'tcc error when building new card', err)
					done(err)


		import: (properties, done) ->
			if !properties.number?
				return done({name:'numberInvalid', message:'Card number empty'})
			card = Card.forge(number: properties.number)
			card.fetch(withRelated:'program').then (existing)->
				if existing? and existing.get('user_id')?
					return done({code:400, name: 'dupCard', message: 'Card has already been imported by someone.'})
				else if existing?
					logger.info 'attaching physical card to user.  card: ', card.attributes
					card.set('user_id', properties.user_id)
					card.TCCSync (err) ->
						return done(err) if err?
						card.save().then (savedCard) ->
							done(null, savedCard)
				else
					return done({code:404, name: 'cardNotFound', message: "No card with that number was found. Please double check the card number and make sure it is part of the Gift It system."})
			###
				else
					#this should never happen because cards should have been activated through our system, consider 
					card.set(properties)	
					card.TCCSync (err) ->
						return done(err) if err?
						card.save().then (savedCard) ->
							done(null, savedCard)

			#).catch (err) ->#done
				logger.error(err)
				done(err)
				###

		refill: (properties, done) ->
			if !properties.amount? or !properties.id? or !properties.nonce?
				return done({code: 400, name:'argumentsInvalid', message: 'You must specify a card, amount, and payment nonce'})
			Card.build properties, (err, card) ->
			Card.forge(id: properties.id, user_id: properties.user_id).fetch().then (card) ->
				return done({code: 400, name:'cardNotFound', message: 'No matching card was found'}) if !card?
				card.refill properties, done

		posFill: (properties, done) ->
			#properties.client_id is the TCC ID called maUid
			program = Program.forge(client_id: properties.client_id).fetch().then (program) ->
				if not program? then return done({code:404, name: 'programNotFound', message: "No program with that id(maUid) was found.  Please use the program ID(maUid) issued by TCC"})
				forgedCard = Card.forge(number: properties.number, program_id: program.get('id'))
				forgedCard.fetch().then (existingCard) ->
					card = existingCard || forgedCard
					card.posFill(properties, done)




		redeem: (properties, done) ->
			logger.info 'card redeeming by properties: ', properties
			searchParameters = {}
			#if we have a user id we are processing an online redemption by a client, otherwise a POS redemption by a physical card  
			if properties.user_id?
				searchParameters = {user_id: properties.user_id, id: properties.id}
			else
				searchParameters = {number: properties.number}

			logger.info 'searching for card to redeem with attributes', searchParameters
			Card.forge(searchParameters).fetch(withRelated:'program').then (card) ->
				logger.info 'found card to redeem', card
				return done({code: 400, name:'cardNotFound', message: 'No matching card was found'}) if !card?
				card.redeem properties, done

		unredeem: (properties, done) ->
			logger.info 'card unredeeming by properties: ', properties
			searchParameters = {}
			#if we have a user id we are processing an online redemption by a client, otherwise a POS redemption by a physical card  
			if properties.user_id?
				searchParameters = {user_id: properties.user_id, id: properties.id}
			else
				searchParameters = {number: properties.number}
			logger.info 'searching for card to redeem with attributes', searchParameters
			Card.forge(searchParameters).fetch(withRelated:'program').then (card) ->
				logger.info 'found card to unredeem', card
				return done({code: 400, name:'cardNotFound', message: 'No matching card was found'}) if !card?
				card.unredeem properties, done


	})
	return Card
			
syncCard = (card, cb) ->
	card.TCCSync (err, card) ->
		return done(err) if err?
		if card.hasChanged()
			card.save().then (savedCard) ->
				cb(null, savedCard)
		else
			cb(null, card)


	