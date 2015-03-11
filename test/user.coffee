request = require('supertest');
setup = require('./libs/setup')
expect = require('chai').expect
userLib = require './libs/user'
userLib.createHooks()

describe 'user', ->
	it 'should get info', (done)->
		userLib.login {}, (session, token) ->
			session.post("/user/info").send({
				token: token
			}).expect(200).end (err, res) ->
				
				#console.log('login response:', res)
				console.log('user info:', res.body)
				expect(res.body).to.exist
				done(err)

	it 'should generate password reset token', (done)->
		this.timeout 15000
		userLib.getUser().then (user) ->
			user.sendPasswordReset () ->
				done()


	it 'should reset password using a valid reset token', (done) ->
		userLib.getUser().then (user) ->
			user.related('tokens').create(type:'reset').then (token) ->
				request.agent(app).post("/user/resetpassword").send({
					key: token.get('key')
					password: 'resetpassword'
					password_confirmation: 'resetpassword'
				}).expect(200).end (err, res) ->
					console.log('reset password with respoonse', res.body)
					userLib.getUser().then (user) ->
						expect(user.validPassword('resetpassword')).to.equal(true)
						done(err)

	it 'should update the user', (done) ->
		userLib.login {}, (session, token) ->
			session.post('/user/update').send({
				token: token
				user:
					password: 'updatedPassword'
					password_confirmation: 'updatedPassword'
					email: 'light24bulbs+newemail@gmail.com'
					first_name: 'newFirstName'
					last_name: 'newLastName'
					display_name: 'newDisplay Name'
				})
			.expect(200)
			.end (err, res) ->
				console.log('response updating user:', res.body)
				done(err)

	it 'should confirm the updated email', (done) ->
		User.where(email: 'light24bulbs@gmail.com').fetch().then (user) ->
			console.log('fetched user to confirm: ', user.attributes)
			session = request.agent(app)
			session
			.get("/user/confirm?token=" + user.get('confirmation_token') )
			.expect(302).end (err, res) ->
				console.log "confirm email with response", res.body
				console.log "confirmation err: ", err
				User.where(email: 'light24bulbs+newemail@gmail.com').fetch().then (confirmed) ->
					expect(confirmed.get('confirmation_token')).to.equal(null)
					console.log('updated user attrs after confirmation: ', confirmed.attributes)
				#console.log('login response:', res)

					done(err)


