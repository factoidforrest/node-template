Promise = require("bluebird")
###
bcrypt = Promise.promisifyAll(require('bcrypt-nodejs'))
crypto = Promise.promisifyAll require 'crypto'
Mail = Promise.promisifyAll require '../../services/mail'
###
crypto = require 'crypto'
moment = require 'moment'
Mail = require '../../services/mail'

module.exports = (bookshelf) ->
	global.Gift = bookshelf.Model.extend({
		tableName: 'gifts'
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

			t.increments().primary().index()
		  t.integer('card_id').notNull().index()
		  t.float('balance')
		  t.string('status').defaultTo('pending')
		  t.integer('from_id').notNull().index()
		  t.string('to_email').notNull().index()
		  t.timestamps()
			###

		from: ->
			return @belongsTo(User, 'from_id')

		card: ->
			return @belongsTo(Card, 'card_id')

		recipient: (done)->
			User.forge({email: this.get('to_email')}).fetch().then (user)->
				if !user?
					return done(false)
				else
					return done(user)

		revoke: (done) ->
			#You must fetch the gift with the related card
			@set('status', 'revoked')
			card = @related('card')
			refundedBalance = card.get('balance') + @get('balance')
			card.set('balance', refundedBalance)
			card.save().then (savedCard) ->
				@save().then (savedGift) ->
					done()

	  	
		#TODO make this safe
		toJSON: ->
			this
	},{
		#class methods
		send: (params, from, done) ->
			if params.email == from.get('email')
				return done('You cannot send a gift to yourself.')
			forged = @forge({
				from_id: from.get('id')
				balance: params.balance
				card_id: params.card
				to_email: params.email
			})

			Card.forge({id: params.card}).fetch().then (card) ->

				if !card?
					return done('No card with this id was found.')
				if card.balance < params.balance
					return done('Not enough value in the card to gift.')
				newBalance = card.get('balance') - params.balance  
				card.set('balance', newBalance)
				card.save().then (savedCard) -> 
					forged.save().then (savedGift) ->
						console.log('saved gift:', savedGift)
						Mail.giftNotify savedGift, from, (err) ->
							if (err)
								logger.error('error sending gift notification email:', err)
							done()





	})
	return Gift
			
