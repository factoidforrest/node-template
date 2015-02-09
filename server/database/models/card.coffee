db = require('./../database')
Promise = require("bluebird")
###
bcrypt = Promise.promisifyAll(require('bcrypt-nodejs'))
crypto = Promise.promisifyAll require 'crypto'
Mail = Promise.promisifyAll require '../../services/mail'
###
crypto = require 'crypto'
moment = require 'moment'

module.exports = (bookshelf) ->
	global.Card = bookshelf.Model.extend({
		tableName: 'tokens'
		hasTimestamps: true


		initialize: () ->
			###
			this.on 'saving', (model, attrs, options) ->
				#I'm aware creating a promise manually like this is considered bad, but using promisification doesn't work so..
				deferred = Promise.pending()
				model.generateToken null, () ->
					logger.info 'token created'
					deferred.fulfill 'token created'
				
				return deferred.promise
			###

		user: ->
			return @hasOne(Authentication)
	  
		#TODO make this safe
		toJSON: ->
			this
		},{
			#class methods

		})
	return Card
			
