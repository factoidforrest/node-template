Promise = require("bluebird")
###
bcrypt = Promise.promisifyAll(require('bcrypt-nodejs'))
crypto = Promise.promisifyAll require 'crypto'
Mail = Promise.promisifyAll require '../../services/mail'
###
crypto = require 'crypto'
moment = require 'moment'
async = require 'async'

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
				done({name:'TCCErr', message: 'Please double check the card number'})
			)

	  json: () ->
	  	return this.attributes
		#THIS IS NOT WORKING, it just doesn't get called
		toJSON: ->
			console.log('converting to json')
			return this.attributes
	},{
		syncGroup : (cards, done) ->
			console.log('syncing card group:', cards)
			async.map cards, syncCard, done
		#class methods

		generate: (properties, done) ->
			#check payment data
			#create card at tcc and use response

		import: (properties, done) ->
			console.log('Card.import called with props', properties)

			if !properties.number?
				return done({name:'numberInvalid', message:'Card number empty'})
			console.log('about to query existing cards')
			card = Card.forge(number: properties.number)
			card.fetch().then((existing)->
				console.log('found existing card:', existing)
				if existing?
					return done({name: 'dupCard', message: 'Card has already been imported'})
				else
					card.set(properties)	
					console.log('set users properties on card:', card.attributes)
					card.TCCSync (err) ->
						console.log('set tcc properties on card:', card.attributes)
						return done(err) if err?
						card.save().then (savedCard) ->
							done(null, savedCard)

			).catch (err) ->#done
				console.log('caught db error:', err)
				done(err)

	})
	return Card
			
syncCard = (card, cb) ->
	card.TCCSync (cb)


	