

request = require('supertest');
setup = require('./libs/setup')
expect = require('chai').expect
userLib = require('./libs/user')

userLib.createHooks()

describe 'Invitations', ->
	this.timeout 10000
	it 'should send', (done) ->
		userLib.login {}, (session, token) ->
			session
			.post('/invitation/send').send(
				token: token
				email: 'light24bulbs+invited@gmail.com'
			).expect(200)
			.end (err, res) ->
				#keep in mind the email won't send because it was sending in the background and mocha kills the server too quickly. 
				console.log('got response inviting user:', res.body)
				done(err)