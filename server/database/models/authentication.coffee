db = require('./../database')
Promise = require("bluebird")
###
bcrypt = Promise.promisifyAll(require('bcrypt-nodejs'))
crypto = Promise.promisifyAll require 'crypto'
Mail = Promise.promisifyAll require '../../services/mail'
###


module.exports = (bookshelf) ->
	global.Authentication = bookshelf.Model.extend({
		tableName: 'authentications'
		hasTimestamps: true


		initialize: () ->
			this.on 'saving', (model, attrs, options) ->
				###
				#I'm aware creating a promise manually like this is considered bad, but using promisification doesn't work so..
				deferred = Promise.pending()
				model.generateToken null, () ->
					logger.info 'token created'
					deferred.fulfill 'token created'
				
				return deferred.promise
				###

		user: () ->
	    return @belongsTo(User)
	  
	  ###
		expired: (timeLength, timeUnits) ->
			if moment().subtract(timeLength, timeUnits).isAfter(@get('createdAt'))
				return true
			else
				return false
		###
		
		#TODO make this safe
		###toJSON: ->

		###
		},{
			findOrCreateGoogle: (accessToken, refreshToken, profile, next) ->

			#class methods

		})
	return Authentication
			
