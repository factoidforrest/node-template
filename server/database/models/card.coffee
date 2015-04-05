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
			TCC.cardInfo(@get('number'), @get('client_id')).then( (data) ->
				newBalance = Number(data.balance)
				console.log('read card data from tcc: ', data)
				card.set('balance', newBalance)
				#card.set('status', data.status) Ignore the TCC status, it doesn't void properly
				done(null, card)
			).catch( (err) ->
				console.log('sync error with tcc', err)
				if err.name == 'connectionError'
					done({name:'connectionError', error:err, message: 'Trouble contacting the card server'})
				else if err.name == 'TCCError'
					done({name:'TCCErr', error: err, message: 'Please double check the card number'})
				else 
					done(err)
			)

		refill: (properties, done) ->
			card = this
			@changeTCCBalance 'add', properties.amount, (err, serial) ->
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

		redeem: (properties, done) ->
			if @balance < properties.amount
				return done({code: 400, name: 'balanceExceeded', message: 'Your card does not have enough value remaining to make this transaction'})
			card = this
			Meal.forge(key: properties.meal_key).fetch().then (meal) ->
				logger.info 'redeeming card on meal: ', meal.attributes
				return done({code: 400, name: 'mealNotFound', message: 'No meal matching that key was found'}) if !meal?
				if meal.get('program_id') != card.get('program_id')
					return done({code:400, name: 'programErr', message: 'Card cannot be used at this restaurant'})
				if meal.get('status') != 'pending'
					return done({code: 400, name: 'mealClosed', message: 'The meal has already been checked out'}) 
				if meal.get('balance') < properties.amount
					return done({code: 400, name: 'overpaid', message: 'Payed more than the cost of the meal'}) 

				Transaction.forge(
					user_id: properties.user_id
					card_number: card.get('number')
					card_id: @get('id')
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
					card.changeTCCBalance 'subtract', properties.amount, (err) ->
						card.save().then (savedCard) ->
							meal.query().decrement('balance', properties.amount).then () ->
								#update decremented meal from database..not super efficient but it works
								Meal.forge({id:meal.get('id')}).fetch(withRelated: ['transactions.card']).then (savedMeal) ->
									done(null, {card: savedCard, meal: savedMeal})

		changeTCCBalance: (action, amount, done) ->
			self = this
			if action == 'add'
				request = TCC.refillCard
			else if action == 'subtract'
				request = TCC.redeemCard
			request(@get('number'), @get('client_id'), amount).then((data) ->
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

		unredeem: (properties, done) ->
			Meal.forge(key: properties.meal_key).fetch().then (meal) ->
				#TODO

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
			card = Card.forge(user_id: properties.user_id, program_id: properties.program_id)
			TCC.createCard(properties.balance, properties.program_id).then((data) ->

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
			card.fetch().then((existing)->
				if existing?
					return done({name: 'dupCard', message: 'Card has already been imported'})
				else
					card.set(properties)	
					card.TCCSync (err) ->
						return done(err) if err?
						card.save().then (savedCard) ->
							done(null, savedCard)

			).catch (err) ->#done
				logger.error(err)
				done(err)

		refill: (properties, done) ->
			if !properties.amount? or !properties.id? or !properties.nonce?
				return done({code: 400, name:'argumentsInvalid', message: 'You must specify a card, amount, and payment nonce'})
			Card.build properties, (err, card) ->
			Card.forge(id: properties.id, user_id: properties.user_id).fetch().then (card) ->
				return done({code: 400, name:'cardNotFound', message: 'No matching card was found'}) if !card?
				card.refill properties, done

		redeem: (properties, done) ->
			logger.info 'card redeeming by properties: ', properties
			Card.forge(id: properties.id, user_id: properties.user_id).fetch().then (card) ->
				logger.info 'found card to redeem', card
				return done({code: 400, name:'cardNotFound', message: 'No matching card was found'}) if !card?
				card.redeem properties, done


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


	