request = require('supertest');
setup = require('./libs/setup')
expect = require('chai').expect
userLib = require('./libs/user')

userLib.createHooks()
session = request.agent(app)
adminToken = null

describe 'admin', ->

	before (done)->
		userLib.createUser {email: 'admin@gmail.com', admin: true}, ->
			session.post("/auth/local").send(
	      email: "admin@gmail.com"
	      password: "secretpassword"
	    ).expect(200).end (err, res) ->
	    	console.log('admin login response ', res.body)
	    	adminToken = res.body.token.key
	    	expect(adminToken).to.exist
	    	done(err)


	it 'should deactivate a user by email', (done) ->
		userLib.createUser {email: 'deactivateme@gmail.com'}, ->
			session
			.post('/admin/deactivateuser').send(
				token: adminToken
				email: 'deactivateme@gmail.com'
			).expect(200)
			.end (err, res) ->
				console.log('deactivated user with response', res.body)
				User.forge(email: 'deactivateme@gmail.com').fetch().then (user) ->
					console.log('deactived user attrs are ', user.attributes)
					expect(user.get('active')).to.equal(false)
					done(err)


	it 'should fail if not an admin', (done)->
		userLib.login {}, (session, normalUserToken) ->

			session.post('/admin/deactivateuser').send(
				token: normalUserToken
				email: 'deactivateme@gmail.com'
			).expect(403)
			.end (err, res) ->
				console.log('got response attempting to access admin functions as normal user:', res.body)
				done(err)

	it 'should get settings', (done)->
		session
		.post('/admin/config').send(
			token: adminToken
		).expect(200)
		.end (err, res) ->
			console.log('got config response:', res.body)
			done(err)

	it 'should set setings', (done) ->
		randomSetting = Math.random() * 10000
		session
		.post('/admin/config').send(
			token: adminToken
			settings: { requestLimit: 500, transactionLimit: randomSetting }
		).expect(200)
		.end (err, res) ->
			console.log('got config response:', res.body)
			expect(res.body.transactionLimit).to.equal(randomSetting)
			done(err)