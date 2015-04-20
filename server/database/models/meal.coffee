Promise = require("bluebird")
###
bcrypt = Promise.promisifyAll(require('bcrypt-nodejs'))
crypto = Promise.promisifyAll require 'crypto'
Mail = Promise.promisifyAll require '../../services/mail'
###
crypto = require 'crypto'
async = require 'async'


module.exports = (bookshelf) ->
	global.Meal = bookshelf.Model.extend({
		tableName: 'meals'
		hasTimestamps: true


		initialize: () ->
			this.on 'saving', (model, attrs, options) ->
				deferred = Promise.pending()
				generateKey model, ->
					deferred.fulfill 'token created'
				return deferred.promise

		
		transactions: ->
			@hasMany(Transaction)


		programs: ->
			@belongsToMany(Program)

		attachPrograms: (clientIds, done) ->
			meal = this
			Program.query('whereIn', 'client_id', clientIds).fetchAll().then (programs) ->
				db.knex('meals_programs').insert(programs.map((program) ->
					return {program_id: program.get('id'), meal_id: meal.get('id')}
				)).then () ->
					meal.load('programs').then (mealWithPrograms) ->
						done(null, mealWithPrograms)



		###
		#not sure through is what we want to use here
		cards: ->
			@hasMany(Card).through(Transaction)
		###
		checkout: (next) ->
			meal = this
			console.log('checking out')
			console.log(@related('transactions').toArray())
			@related('transactions').each (transaction) ->
				transaction.set('status', 'closed')
			@set('status', 'closed')
			@related('transactions').invokeThen('save').then () ->
				meal.save().then () ->
					next(null, meal)
			


	},{
			#class methods

		})
	return Meal

#need to check the key didn't already exist, probably pointless but could prevent strange errors someday
generateKey = (model, next) ->
	require('crypto').randomBytes 8, (ex, buf) ->
		key = buf.toString('hex')
		Meal.forge(key:key).fetch().then (existingMeal) ->
			if existingMeal?
				#can't figure out how to test this so there is a small possibility it will break.  It will probably never happen anyway
				console.log('meal key already existed, generating another')
				generateKey(model, next)
			else
				console.log('meal key is unique, saving')
				model.set 'key', key
				next()


			
