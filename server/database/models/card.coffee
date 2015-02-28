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
	},{

		#this also saves the changes to the database, if there were any
		syncGroup : (cards, done) ->
			#this needs to somehow handle when one of the cards throws an error
			console.log('syncing card group:', JSON.stringify(cards))
			async.map cards, syncCard, done
		

		#create
		generate: (properties, done) ->
			if !properties.balance? or !properties.program? or !properties.nonce?
				return done({name:'argumentsInvalid', message: 'You must specify a restaurant, amount, and payment method'})

			Payment.authorize properties.balance, properties.nonce, (authErr, authorization) ->

				if authErr?
					return done(authErr)
				console.log('authorized payment ', authorization)
				card = Card.forge(user_id: properties.user_id, program_id: properties.program)
				TCC.createCard(authorization.transaction.amount, properties.program).then((data) ->
					Payment.settle authorization.transaction, (settleErr, settlement) ->
						if settleErr?
							#need to handle canceling the card at tcc!!!!!!!
							logger.error('Settlement error: ', settleErr)
							return done(settleErr)

						card.set('balance', settlement.transaction.amount)
						card.set('status', data.status)
						card.set('number', data.card_number)

						card.save().then (savedCard) ->

							Transaction.forge(
								user_id: properties.user_id
								card_id: savedCard.get('id')
								card_number: savedCard.get('number')
								amount: card.get('balance')
								type: 'purchase'
								status: settlement.transaction.status
								data: {authorization: authorization.transaction, settlement: settlement.transaction}
							).save().then (savedTransaction) ->
								console.log('saved transaction ', savedTransaction)
								done(null, savedCard)

				).catch( (err) ->
					console.log('tcc error', err)
					logger.error(err)
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
			Card.forge(id: properties.id).fetch().then (card) ->
				return done({code: 400, name:'cardNotFound', message: 'No matching card was found'}) if !card?
				card.refill properties.balance, done



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


	