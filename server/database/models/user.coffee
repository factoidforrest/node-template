db = require('./../database')
#Promise = require("bluebird")
###
bcrypt = Promise.promisifyAll(require('bcrypt-nodejs'))
crypto = Promise.promisifyAll require 'crypto'
Mail = Promise.promisifyAll require '../../services/mail'
###
bcrypt = require('bcrypt-nodejs')
crypto = require 'crypto'
Mail = require '../../services/mail'


module.exports = (bookshelf) ->
	global.User = bookshelf.Model.extend({
		tableName: 'users'
		hasTimestamps: true

		###
		cards: () ->
			@hasMany(db.models.card)
		###

		initialize: () ->

		#relations
		tokens: ->
			return @morphMany(Token, 'tokenable')

		authentications: ->
			return @hasMany(Authentication)

		cards: ->
			return @hasMany(Card)
		createToken: ->
			#returns a promise
			@related('tokens').create()
		
		validPassword: (password) ->
			logger.info "checking password"
			
			#would be more efficient to do this async, can figure that out once load becomes a problem
			valid = false
			valid = bcrypt.compareSync(password, @get('password'))
			logger.info "correct password? : ", valid
			return valid

		#deprecated
		setPassword: (password, next) ->
			self = this
			bcrypt.hash password, null, null, (err, hash) ->
				return next(err)  if err
				self.set 'password', hash
				next()

			return

		name: () ->
			@get('firstname') + ' ' + @get('lastname')

		#promisification on this doesnt seem to work, so its deprecated
		hashPassword: (password) -> 
			console.log('hashing password')
			#promise
			self = this
			return bcrypt.hash(password, null, null).then (hash) ->
				console.log('hash created')
				self.set('password', hash)
				return

		generateToken: (next) ->
			console.log('generating token')
			self = this
			return crypto.randomBytes(48, (ex, buf) ->
				console.log('token generated')
				key = buf.toString("hex")
				self.set('confirmation_token', key)
				next()
			)

		sendConfirmationEmail: (done) ->
			#promise
			return Mail.sendConfirmation @attributes, null,  done

		setupLocalUser: (password) ->
			#promise
			@setPassword password, (err) ->
				@generateToken

			#.then(sendConfirmationEmail) do after



		
		#TODO make this safe
		toJSON: ->
			@attributes

		},{
			#class methods
			confirmEmail: (token, next) ->
				console.log "searching for user with token:", token
				User.where(confirmation_token: token).fetch().then (user) ->
					return next("Invalid token")  if user is null or typeof (user) is "undefined"
					logger.info "found user to confirm by token: ", user
					return next("This user is already confirmed, please log in.")  if user.get('confirmation_token') is null
					
					#swap with new email if the user was updating an existing email
					user.set('email', user.new_email) if user.hasOwnProperty("new_email")
					user.set('confirmation_token', null)
					user.save().then (saved) ->
						logger.info "updated user to remove token: ", saved
						next()
						return

					return

				return
		})
	return User
			
