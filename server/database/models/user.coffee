
bcrypt = require('bcrypt-nodejs')
crypto = require 'crypto'
Mail = require '../../services/mail'


module.exports = (bookshelf) ->
	global.User = bookshelf.Model.extend({
		tableName: 'users'
		hasTimestamps: true
		#https://github.com/tgriesser/bookshelf/wiki/Plugin:-Visibility
		hidden: ['password', 'confirmation_token']
		#https://github.com/tgriesser/bookshelf/wiki/Plugin:-Virtuals
		virtuals: {
			###
	    fullName: function() {
	        return this.get('firstName') + ' ' + this.get('lastName');
	    }
	    ###
	  }

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
			
		createToken: (attrs) ->
			#returns a promise
			console.log('creating token with attributes', attrs)
			@related('tokens').create(attrs)
		
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
			if @get('first_name')?
				@get('first_name') + ' ' + @get('last_name')
			else
				@get('email')

		#promisification on this doesnt seem to work, so its deprecated
		hashPassword: (password) -> 
			console.log('hashing password')
			#promise
			self = this
			return bcrypt.hash(password, null, null).then (hash) ->
				console.log('hash created')
				self.set('password', hash)
				return

		generateConfirmationToken: (next) ->
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

		setupLocalUser: (password, next) ->
			self = this
			self.setPassword password, () ->
				self.generateConfirmationToken () ->
					self.save().then (saved)->
						console.log "the user was saved as", saved
						#res.json({success: true, errors: {}})
						self.sendConfirmationEmail (err) ->
							return logger.error 'email error' + err if err
							logger.info 'email sent'

						next(null)

		sendPasswordReset: (next) ->
			user = this
			@related('tokens').create(type:'reset').then (token) ->
				console.log('created reset token:', token)
				Mail.sendPasswordReset(user, token, next)

		json: ->
			return {
				id: @get('id')
				name: @name()
				email: @get('email')
				admin: @get('admin')
			}
			
		#this just doesnt work
		###
		toJSON: ->
			@attributes
		###
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

			findOrCreate: (profile, callback) ->
				User.where(email:profile.email).fetch().then (user) ->
					if user?
						console.log('associating existing user to authentication', user)
						#we could set the names if we didn't have them in the user
						return callback(user)
					else
						User.forge(
							email: profile.email
							first_name: profile.first_name
							last_name: profile.last_name
							display_name: profile.display_name
						).save().then (newUser) ->
							console.log('saved new user for authentication', newUser)
							#need to set this to avoid another database call.  It is set automatically by the database but knex doesn't know that here so we just set it manually
							newUser.set('active', true)
							return callback(newUser)

			invite: (email, from, done) ->
				

		})

			
	return User
			
