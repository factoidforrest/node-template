

objectAssign = require('object-assign')
setup = require './setup'
hooksCreated = false
request = require("supertest")

module.exports.createHooks = (params) ->
	unless hooksCreated
		before (done) ->
			module.exports.createUser params, done
		after (done) ->
			setup.destroy(User, done)



module.exports.createUser = (params, done) ->
	console.log 'hooks created?', hooksCreated
	params ?= {}
	userProperties = 
		email: 'light24bulbs@gmail.com'
		last_name: 'testLast'
		first_name: 'testFirst'
	objectAssign userProperties, params
	User.forge(userProperties).save().then (user) ->
		user.set('confirmation_token', null)
		user.setPassword 'secretpassword', ->
			user.save().then (user) ->
				console.log('created user with properties: ', user.attributes)
				#maybe not great since we could call this method without creating any lifecycle hooks
				hooksCreated = true
				#console.log('created user for testing:', user)
				done()
 
module.exports.manuallyDestroyUser = (done) ->
	setup.destroy(User, done)

module.exports.getUser = () ->
	User.where(email: 'light24bulbs@gmail.com').fetch()


savedSession = null
savedToken = null
module.exports.login = (params, callback) ->
	params ?= {}
	if !savedSession or params? and params.email?
		session = request.agent(app)
		userDetails =  {email: "light24bulbs@gmail.com", password: "secretpassword"}
		objectAssign userDetails, params
		session.post("/auth/local").send(userDetails).expect(200).end (err, res) ->
			
			#console.log('login response:', res)
			console.log "logged in to new session with response", res.body
			console.log "login err: ", err
			savedSession = session
			savedToken = res.body.token.key
			callback session, res.body.token.key
			return

	else
		console.log "using saved session"
		callback savedSession, savedToken
	return
