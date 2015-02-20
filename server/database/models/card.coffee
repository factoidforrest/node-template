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

		sync: (done) ->
			card = this
			TCC.cardInfo(@get('number')).done (err, data) ->
				#HANDLE SYNC ERROR
				if err?
					return done(err)
				if card.get('balance') != data.balance
					card.set('balance', data.balance)
					card.save().then (saved) ->
						done(null, saved)
				else
					done(null, card)

	  json: () ->
	  	return this.attributes
		#THIS IS NOT WORKING, it just doesn't get called
		toJSON: ->
			console.log('converting to json')
			return this.attributes
		},{
			syncGroup : (cards) ->
				async.map cards, syncCard, (err, synced) ->
					console.log('cards synced: ', synced)
			#class methods

		})
	return Card
			
syncCard = (card, cb) ->
	card.sync (cb)
