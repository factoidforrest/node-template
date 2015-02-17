Promise = require("bluebird")
###
bcrypt = Promise.promisifyAll(require('bcrypt-nodejs'))
crypto = Promise.promisifyAll require 'crypto'
Mail = Promise.promisifyAll require '../../services/mail'
###
crypto = require 'crypto'


module.exports = (bookshelf) ->
	global.Meal = bookshelf.Model.extend({
		tableName: 'meals'
		hasTimestamps: true


		initialize: () ->
			this.on 'saving', (model, attrs, options) ->
				deferred = Promise.pending()
				require('crypto').randomBytes 4, (ex, buf) ->
		      model.set 'key', buf.toString('hex')
		      deferred.fulfill 'token created'
				return deferred.promise

	  
		#TODO make this safe
		toJSON: ->
			this
		},{
			#class methods

		})
	return Meal
			
