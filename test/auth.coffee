
app = require('../server')
request = require('supertest');
setup = require('./libs/setup')
expect = require('chai').expect
userLib = require('./libs/user')


describe 'user', ->

	before userLib.manuallyDestroyUser

	it 'sign up', (done) ->
		this.timeout(10000)
		session = request.agent(app)
		session.post("/auth/register").send({
			email: "light24bulbs@gmail.com"
			password: "secretpassword"
			passwordConfirmation: 'secretpassword'
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
			
			#console.log('login response:', res)
			console.log "logged in to new session with response", res.body
			console.log "login err: ", err
			done(err)

	###
	it 'sign up with google', (done) ->
		session = request.agent(app)
		session.post("/auth/google/authcode").send({
			code: "4/Oome4iVqJR78ucG65hjOJO2-Dcf1OYNgAhUNtpJCAAM.snfqCoSQ1nMZoiIBeO6P2m-OLPHTlgI"
		}).expect(200).end (err, res) ->
			#console.log('login response:', res)
			console.log "google authenticated with response", res
			console.log "login err: ", err
			done(err)
	###
		