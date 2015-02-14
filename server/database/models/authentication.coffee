db = require('./../database')
Promise = require("bluebird")
###
bcrypt = Promise.promisifyAll(require('bcrypt-nodejs'))
crypto = Promise.promisifyAll require 'crypto'
Mail = Promise.promisifyAll require '../../services/mail'
###
#google stuff
google = require('googleapis')
OAuth2 = google.auth.OAuth2;
plus = google.plus('v1')


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
			findOrCreateGoogle: (accessToken, refreshToken, next) ->
				console.log('google credentials: ', process.env.GOOGLE_ID, process.env.GOOGLE_SECRET )
				oauth2Client = new OAuth2(
					process.env.GOOGLE_ID,
					process.env.GOOGLE_SECRET
				)
				# Retrieve tokens via token exchange explained above or set them:
				oauth2Client.setCredentials
					access_token: accessToken
					refresh_token: refreshToken
				plus.people.get {
					userId: 'me'
					auth: oauth2Client
				}, (err, data) ->
					if err?
						logger.info 'Google api error', err
						return next(err)
					
					profile = {
						uid : data.id
						provider: 'google'
						email: data.emails[0].value
						name: data.displayName
						access_token: accessToken
						refresh_token: refreshToken
					}
					findOrCreate(profile, next)
					

		})
	return Authentication
			
findOrCreate = (profile, next) ->
	logger.info('finding or creating auth from', profile)
	forgedAuth = Authentication.forge({uid: profile.uid, provider: profile.provider})

	#check if already authenticated using this provider
	forgedAuth.fetch({withRelated: ['user']}).then (auth) ->
		if auth?
			console.log 'found existing authentication', auth
			console.log 'with related user', auth.relations.user
			return next(null, auth.relations.user)
		else
			forgedAuth.set(
				email: profile.email
				name: profile.name
			)
			console.log 'creating new auth', forgedAuth
			User.findOrCreate forgedAuth, (user) ->
				forgedAuth.set('user_id', user.get('id'))
				console.log 'saving new authentication', forgedAuth
				forgedAuth.save().then (newAuth) ->
					return next(null, user)



