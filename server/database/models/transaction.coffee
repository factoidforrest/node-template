
bcrypt = require('bcrypt-nodejs')
crypto = require 'crypto'
Mail = require '../../services/mail'


module.exports = (bookshelf) ->
	global.Transaction = bookshelf.Model.extend({
		tableName: 'transactions'
		hasTimestamps: true

		hidden: ['data']
		#https://github.com/tgriesser/bookshelf/wiki/Plugin:-Virtuals
		virtuals: {
			
			
		}



		#relations
		#doesnt always have a meal, depending on the transaction type
		meal: ->
			return @belongsTo(Meal)
		user: ->
			return @belongsTo(User)

		card: ->
			return @belongsTo(Card)
			
		},{
			#class methods

		})
		
	return Transaction
			
