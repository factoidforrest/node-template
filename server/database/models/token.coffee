db = require('./../database')
Promise = require("bluebird")
###
bcrypt = Promise.promisifyAll(require('bcrypt-nodejs'))
crypto = Promise.promisifyAll require 'crypto'
Mail = Promise.promisifyAll require '../../services/mail'
###
crypto = require 'crypto'


module.exports = (bookshelf) ->
	global.Token = bookshelf.Model.extend({
		tableName: 'tokens'
		hasTimestamps: true

		###
		cards: () ->
			@hasMany(db.models.card)
		###

		initialize: () ->
			#I'm aware creating a promise manually like this is considered bad, but using promisification doesn't work so..
			deferred = Promise.pending()
			@generateToken null, () ->
				logger.info 'token created'
				deferred.fulfill 'token created'
			 
			return deferred.promise

		generateToken: (length, next) ->
			length or= 48
			console.log('generating token')
			self = this
			return crypto.randomBytes(length, (ex, buf) ->
				console.log('token generated')
				key = buf.toString("hex")
				self.set('key', key)
				next()
			)

		valid: (date) ->

		
		#TODO make this safe
		toJSON: ->
			key: @get('key')
		},{
			#class methods

		})
	return Token
			
