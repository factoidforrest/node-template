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
		virtuals: 
			description: () ->
				if @related('card')?	
					return @related('card').related('program').get('description')
				else
					return 'Description not available'



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
			self = this
			#You must fetch the gift with the related card
			if @get('status') != 'pending'
				return done({code: 400, name:'cantRevoke', message: 'This gift is ' + @get('status') + ' and cannot be revoked'})
			card = @related('card')
			#refundedBalance = card.get('balance') + @get('balance')
			#card.set('balance', refundedBalance)
			card.changeTCCBalance 'add', {location_id: 1, amount: @get('balance')}, (err) ->
				return done(err) if err?
				self.set('status', 'revoked')


				card.save().then (savedCard) ->
					self.save().then (savedGift) ->
						done(null, savedGift)

		accept: (user, done) ->
			self = this
			self.set('status', 'sent')
			from_card = self.related('card')

			cardProperties = {
				user_id: user.get('id')
				program_id: from_card.get('program_id')
				balance: self.get('balance')
			}
			Card.build cardProperties, (err, card) ->
				if err?
					return done(err)
				self.save().then ->
					done(null, card)



	},{
		#class methods
		send: (params, from, done) ->



			forgedGift = @forge(params)

			Card.forge({id: params.card_id, user_id: params.from_id}).fetch(withRelated: ['program']).then (card) ->
				if !card?
					return done({err:'cardNotFound', code: 404, message: 'No card with this ID belonging to you was found.'})
				card.TCCSync (err) ->
					return done(err) if err?
					if card.get('balance') < params.balance
						return done(code: 400, name:'insufficientFunds', message: 'Not enough value in the card to gift.')
					card.changeTCCBalance 'subtract', {location_id: 1, amount: params.balance}, (err) ->
						return done(err) if err?
						card.save().then (savedCard) -> 
							forgedGift.save().then (savedGift) ->
								console.log('saved gift:', savedGift)
								Mail.giftNotify savedGift, card.get('description'), from, (err) ->
									if (err)
										logger.error('error sending gift notification email:', err)
									done(null, savedGift)




	})
	return Gift
			
