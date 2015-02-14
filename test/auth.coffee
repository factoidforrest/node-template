

request = require('supertest');
setup = require('./libs/setup')
expect = require('chai').expect
userLib = require('./libs/user')

key = null
describe 'user', ->

	before userLib.manuallyDestroyUser

	it 'sign up', (done) ->
		this.timeout(10000)
		session = request.agent(app)
		session.post("/auth/register").send({
			email: "light24bulbs@gmail.com"
			password: "secretpassword"
			password_confirmation: 'secretpassword'
		}).expect(200).end (err, res) ->
			
			#console.log('login response:', res)
			console.log "created user with response", res.body
			console.log "login err: ", err
			done(err)


	it 'confirm email', (done) ->
		User.where(email: 'light24bulbs@gmail.com').fetch().then (user) ->
			session = request.agent(app)
			session
			.get("/user/confirm?token=" + user.get('confirmation_token') )
			.expect(302).end (err, res) ->
				console.log "logged in to new session with response", res.body
				console.log "login err: ", err
				User.where(email: 'light24bulbs@gmail.com').fetch().then (confirmed) ->
					expect(confirmed.get('confirmation_token')).to.equal(null)
				#console.log('login response:', res)

					done(err)


	it 'local sign in', (done) ->
		session = request.agent(app)
		session.post("/auth/local").send(
			email: "light24bulbs@gmail.com"
			password: "secretpassword"
		).expect(200).end (err, res) ->
			expect(res.body.token.key).to.exist
			#console.log('login response:', res)
			console.log "logged in to new session with response", res.body
			console.log "login err: ", err
			done(err)

	###
	it 'sign up with google', (done) ->
		this.timeout = 15000
		session = request.agent(app)
		session.post("/auth/google/authcode").send({
			code: "4/zO9UmylJBV6Cme2VGPA9end-ZcsLTwLoGwANk9RO-hQ.wp-RwG_Y1pIWoiIBeO6P2m982x8QlwI"
		}).expect(200).end (err, res) ->
			#console.log('login response:', res)
			console.log "google authenticated with response", res
			console.log "login err: ", err
			done(err)
	###

	it 'test google api with new auth', (done) ->
		this.timeout 15000
		Authentication.findOrCreateGoogle(
			'ya29.GgHyg6LixugCR5nDV-9UV6cNQWmW-5auXDjxKacVpr84CQbL__QS2-jEhmPtlvVMx3vl_e65r5nR2g',
			'1/q9Vt7hh9Z-5iQZc0-zRpyXNWJxSgCqNtJTFpYsu2vlU',
			(err, user) ->
				console.log('got err ', err)
				console.log('got user from auth google create', user)
				expect(user).to.exist
				done(err)
		)

	it 'test google api with already existing auth', (done) ->
		this.timeout 15000
		Authentication.findOrCreateGoogle(
			'ya29.GgHyg6LixugCR5nDV-9UV6cNQWmW-5auXDjxKacVpr84CQbL__QS2-jEhmPtlvVMx3vl_e65r5nR2g',
			'1/q9Vt7hh9Z-5iQZc0-zRpyXNWJxSgCqNtJTFpYsu2vlU',
			(err, user) ->
				console.log('got err ', err)
				console.log('got user from auth google create', user)
				expect(user).to.exist
				done(err)
		)

	it 'test google signin using mobile gift card api', (done) ->
		session = request.agent(app)
		session.post("/auth/google/clientside").send(
			access_token: 'ya29.GgHyg6LixugCR5nDV-9UV6cNQWmW-5auXDjxKacVpr84CQbL__QS2-jEhmPtlvVMx3vl_e65r5nR2g'
			refresh_token: '1/q9Vt7hh9Z-5iQZc0-zRpyXNWJxSgCqNtJTFpYsu2vlU'
		).expect(200).end (err, res) ->
			
			#console.log('login response:', res)
			console.log "google signed in with response", res.body
			console.log "login err: ", err
			expect(res.body.token.key).to.exist
			key = res.body.token.key
			done(err)

	it 'token return from google signin should be valid', (done) ->
		session = request.agent(app)
		session.post("/user/testtoken").send({
			token: key
		}).expect(200).end (err, res) ->
			
			#console.log('login response:', res)
			console.log('authenticated with token and got response:', res.body)
			done(err)
	


		