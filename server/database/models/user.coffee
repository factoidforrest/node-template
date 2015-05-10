
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
			
			name: () -> 
				if !!this.get('display_name')
					return this.get('display_name')
				else if !!this.get('first_name')
					return this.get('first_name') + ' ' + this.get('last_name')
				else
					return this.get('email')
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

		transactions: ->
			return @hasMany(Transaction)

		#for users who manage programs, like restaurant owners
		managedPrograms: ->
			return @belongsToMany(Programs)
			
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
			return Mail.sendConfirmation @attributes, @get('new_email'),  done

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

		update: (properties, next) ->
			try
				user = this
				console.log('user is', user)
				@set(
					first_name: properties.first_name
					last_name: properties.last_name
					display_name: properties.display_name
					)
				#we are dropping the error for email confirmation and not waiting for it to finish by passing an empty callback
				if properties.email != user.get('email')
					user.set('new_email', properties.email)
					user.generateConfirmationToken () ->
						user.sendConfirmationEmail(->)
						setupPassword()
				else
					setupPassword()

				setupPassword = ->
					if !!properties.password
						if properties.password isnt properties.password_confirmation
							return next({code:400, name: 'passwordConfirmation', field: 'password', message: "Passwords didn't match."})
						if properties.password.length < 6
							return next({code:400, name: 'passwordTooShort', field: 'password', message: "Passwords didn't match."})
						user.setPassword properties.password, -> 
							user.save().then (savedUser) ->
								next()
					else
						user.save().then (user) ->
							next()
			#hacks because errors aren't propogating properly in testing.  
			catch e
				console.log("THROWING ERROR ", e, e.stack)
				e.code = 500
				next(e)



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
					return next({code: 400, name: 'tokenInvalid', message:"Invalid token"})  if not user?
					logger.info "found user to confirm by token: ", user.attributes
					return next({code: 400, name: 'alreadyConfirmed', message: "This user is already confirmed, please log in."})  if user.get('confirmation_token') is null
					
					#swap with new email if the user was updating an existing email
					if user.get("new_email")?
						user.set('email', user.get('new_email')) 
						user.set('new_email', null)
					user.set('confirmation_token', null)
					user.save().then (saved) ->
						logger.info "updated user to confirm their email: ", saved
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
			
