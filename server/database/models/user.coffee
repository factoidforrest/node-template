bcrypt = require("bcrypt-nodejs")
db = require('./../database')

module.exports = (bookshelf) ->
	User = bookshelf.Model.extend({
		tableName: 'users'
		hasTimestamps: true

		###
		cards: () ->
			@hasMany(db.models.card)
		###

		initialize: () ->


		validPassword: (password) ->
			logger.info "checking password"
			
			#would be more efficient to do this async, can figure that out once load becomes a problem
			valid = false
			valid = bcrypt.compareSync(password, @get('password'))
			logger.info "correct password? : ", valid
			return valid

		setPassword: (password, next) ->
			self = this
			bcrypt.hash password, null, null, (err, hash) ->
				return next(err)  if err
				self.set 'password', hash
				next()

			return

		name: () ->
			@get('firstname') + ' ' + @get('lastname')

		toJSON: ->
			created_at: @createdAt
			email: @email
			id: @id
			last_name: @lastname
			full_name: @name
			updated_at: @updatedAt
			first_name: @firstname
			email: @email
			admin: @admin
		},{
			#class methods
			confirmEmail: (token, next) ->
				console.log "searching for user with token:", token
				User.findOne(token: token).done (err, user) ->
					return next(err)  if err
					return next("Invalid token")  if user is null or typeof (user) is "undefined"
					console.log "found user to confirm by token: ", user
					return next("This user is already confirmed, please log in.")  if user.token is null
					
					#swap with new email if the user was updating an existing email
					user.email = user.new_email  if user.hasOwnProperty("new_email")
					user.token = null
					user.save (error) ->
						return next(error)  if error
						console.log "updated user to remove token: ", user
						next()
						return

					return

				return

			beforeCreate: (attrs, next) ->
				console.log "user before create called and the attributes are"
				console.log attrs
				
				#bcrypt = require("bcrypt")
				#User.findByEmail(attrs.email).done(function(err, user){
				#  console.log('found users matching email: ', user)
				#});
				if typeof (attrs.password) isnt "undefined" #(attrs.strategy === 'local'){
					console.log "converting password to hash"
					bcrypt.hash attrs.password, null, null, (err, hash) ->
						return next(err)  if err
						attrs.password = hash
						delete (attrs.passwordConfirmation)

						
						#should check the key is unique but it's probably ok not to since the chances of two being the same are insanely small
						require("crypto").randomBytes 48, (ex, buf) ->
							attrs.token = buf.toString("hex")
							Mail.sendConfirmation attrs, next
							return

						return

				else
					next()
				return

			afterCreate: (attrs, next) ->
				next()
				return
		})
	return User
			
