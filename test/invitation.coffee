

request = require('supertest');
setup = require('./libs/setup')
expect = require('chai').expect
userLib = require('./libs/user')

userLib.createHooks()

describe 'Invitations', ->
	it 'should send', (done) ->
		userLib.login {}, (session, token) ->
			session
			.post('/invitation/send').send(
				token: token
				email: 'light24bulbs+invited@gmail.com'
			).expect(200)
			.end (err, res) ->
				console.log('got response inviting user:', res.body)
				done(err)