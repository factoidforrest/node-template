

request = require('supertest');
setup = require('./libs/setup')
expect = require('chai').expect
userLib = require('./libs/user')

key = null

describe 'authentication', ->
	this.timeout(20000)

	before userLib.manuallyDestroyUser
	signUp = (email, done) ->
		session = request.agent(app)
		session.post("/auth/register").send({
			email: email
			password: "secretpassword"
			password_confirmation: 'secretpassword'
		}).expect(200).end (err, res) ->
			
			#console.log('login response:', res)
			console.log "created user with response", res.body
			console.log "creation err: ", err
			done(err)

	it 'sign up', (done) ->
		this.timeout(10000)
		signUp('light24bulbs@gmail.com', done)


	it 'confirm email', (done) ->
		User.where(email: 'light24bulbs@gmail.com').fetch().then (user) ->
			session = request.agent(app)
			session
			.get("/user/confirm?token=" + user.get('confirmation_token') )
			.expect(302).end (err, res) ->
				console.log "confirm email with response", res.body
				console.log "confirmation err: ", err
				User.where(email: 'light24bulbs@gmail.com').fetch().then (confirmed) ->
					expect(confirmed.get('confirmation_token')).to.equal(null)
				#console.log('login response:', res)

					done(err)

	it 'sign up again', (done) ->
		this.timeout(10000)
		signUp('light24bulbs+confirmjson@gmail.com', done)		

	it 'confirm email through json api', (done) ->
		User.where(email: 'light24bulbs+confirmjson@gmail.com').fetch().then (user) ->
			session = request.agent(app)
			session
			.post("/user/confirm_json")
			.send(confirmation_token: user.get('confirmation_token'))
			.expect(200).end (err, res) ->
				console.log('got response confirming via json', res.body)
				done(err)

	it 'confirm email should fail when already confirmed', (done) ->
		User.where(email: 'light24bulbs@gmail.com').fetch().then (user) ->
			session = request.agent(app)
			session
			.get("/user/confirm?token=" + user.get('confirmation_token') )
			.expect(302).end (err, res) ->
				console.log "confirm email with response", res.body
				console.log "confirmation err: ", err
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

	it 'local sign up on a third party account', (done)->
		User.forge(email:'light24bulbs+prexisting@gmail.com').save().then (user) ->
			request.agent(app).post("/auth/register").send({
				email: "light24bulbs+prexisting@gmail.com"
				password: "secretpassword"
				password_confirmation: 'secretpassword'
			}).expect(200).end (err, res) ->
				
				#console.log('login response:', res)
				console.log "created new password on prexisting user with response", res.body
				console.log "creation err: ", err
				User.where(email:'light24bulbs+prexisting@gmail.com').fetch().then (fetched) ->
					console.log('user was updated to ', fetched)
					expect(fetched.get('password')).to.exist
					done(err)

	it 'wait for emails to send...hacks for now', (done) ->
		setTimeout(done, 10000)

