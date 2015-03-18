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

		#doesn't save, just updates in place
		TCCSync: (done) ->
			console.log('syncing card')
			card = this
			TCC.cardInfo(@get('number')).then( (data) ->
				newBalance = Number(data.balance)
				console.log('read card data from tcc: ', data)
				card.set('balance', newBalance)
				card.set('status', data.status)
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

		refill: (amount, done) ->
			card = this
			TCC.refillCard(this.get('number'), amount).then((data) ->
				card.set({balance: data.balance, status: data.status})
				card.save().then () ->
					done(null, card)
			).catch (err) ->
				console.log('sync error with tcc', err)
				if err.name == 'connectionError'
					done({code: 500, name:'connectionError', error:err, message: 'Trouble contacting the card server'})
				else if err.name == 'TCCError'
					done({code: 500, name:'TCCErr', error: err, message: 'Please double check the card number'})
				else 
					done(err)

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

					TCC.redeemCard(card.get('number'), properties.amount).then((tccResponse) ->
						console.log 'got redeemed card: ', tccResponse
						card.set(balance:tccResponse.balance).save().then (savedCard) ->
							meal.query().decrement('balance', properties.amount).then () ->
								#update decremented meal from database..not super efficient but it works
								Meal.forge({id:meal.get('id')}).fetch(withRelated: ['transactions.card']).then (savedMeal) ->
									done(null, {card: savedCard, meal: savedMeal})
						return
					).fail (err) ->
						done err
						#need to use the SQL decrement to avoid race condition of just doing it node side

		unredeem: (properties, done) ->
			Meal.forge(key: properties.meal_key).fetch().then (meal) ->




	},{

		#this also saves the changes to the database, if there were any
		syncGroup : (cards, done) ->
			#this needs to somehow handle when one of the cards throws an error
			console.log('syncing card group:', JSON.stringify(cards))
			async.map cards, syncCard, done
		

		#create
		generate: (properties, done) ->
			if !properties.balance? or !properties.program? or !properties.nonce?
				return done({code: 400, name:'argumentsInvalid', message: 'You must specify a restaurant, amount, and payment method'})

			Payment.authorize properties.balance, properties.nonce, (authErr, authorization) ->

				if authErr?
					return done(authErr)
				console.log('authorized payment ', authorization)
				card = Card.forge(user_id: properties.user_id, program_id: properties.program)
				TCC.createCard(authorization.transaction.amount, properties.program).then((data) ->
					Payment.settle authorization.transaction, (settleErr, settlement) ->
						if settleErr?
							#need to handle canceling the card at tcc!!!!!!!
							return done(settleErr)

						card.set('balance', settlement.transaction.amount)
						card.set('status', data.status)
						card.set('number', data.card_number)

						card.save().then (savedCard) ->

							Transaction.forge(
								user_id: properties.user_id
								card_id: savedCard.get('id')
								card_number: savedCard.get('number')
								amount: settlement.transaction.amount
								type: 'purchase'
								status: settlement.transaction.status
								data: {authorization: authorization.transaction, settlement: settlement.transaction}
							).save().then (savedTransaction) ->
								logger.info('transaction saved: ', savedTransaction)
								done(null, savedCard)

				).catch( (err) ->
					logger.error('tcc error', err)
					done(err)
				)

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
			Card.forge(id: properties.id, user_id: properties.user_id).fetch().then (card) ->
				return done({code: 400, name:'cardNotFound', message: 'No matching card was found'}) if !card?
				card.refill properties.balance, done

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


	