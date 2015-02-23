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
				if card.get('balance') != newBalance
					console.log('updating out of date card')
					card.set('balance', data.balance)
					card.save().then (saved) ->
						done(null, saved)
				else
					console.log('card balance already up to date, continuing')
					done(null, card)
				).catch( (err) ->
					console.log('sync error with tcc', err)
					done(err)
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
			

	})
	return Card
			
syncCard = (card, cb) ->
	card.TCCSync (cb)
