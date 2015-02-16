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

#facebook
FB = require 'fb'
FB.api 'oauth/access_token', {
	client_id: '332366616957466',
	client_secret: 'd9a99a29bf4ac4e02ba496a6fd04f37b',
	grant_type: 'client_credentials'
},  (res) ->
	if !res || res.error
		logger.error('Error assigning facebook token, facebook auth WILL NOT WORK ' + !res ? '' : res.error)
		return
	accessToken = res.access_token
	logger.info 'Got facebook access token, storing'
	FB.setAccessToken(accessToken)


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
					console.log('got google data', data)
					profile = {
						uid : data.id
						provider: 'google'
						email: data.emails[0].value
						display_name: data.displayName
						first_name: data.name.givenName
						last_name: data.name.familyName
						#not storing these tokens for now
						access_token: accessToken
						refresh_token: refreshToken
					}
					console.log('profile is ', profile)
					findOrCreate(profile, next)

			findOrCreateFacebook: (token, next) ->
				FB.api 'me', {
					access_token: token
					scope: 'email'
				},  (data) ->
					console.log('checked facebook user data with response', data)
					if !data || data.error
						errorMessage = !data ? 'Error getting facebook api data' : data.error
						logger.error(errorMessage)
						return next(errorMessage)
					profile = {
						uid: data.id
						provider: 'facebook'
						email: data.email
						first_name: data.first_name
						last_name: data.last_name
						display_name: data.name
					}

					findOrCreate(profile, next)
					
					


				
									

		})
	return Authentication
			

findOrCreate = (profile, next) ->
	if not profile.email?
		return next('No email associated with this account')
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
				name: profile.display_name
			)
			console.log 'creating new auth', forgedAuth
			User.findOrCreate profile, (user) ->
				forgedAuth.set('user_id', user.get('id'))
				console.log 'saving new authentication', forgedAuth
				forgedAuth.save().then (newAuth) ->
					return next(null, user)



