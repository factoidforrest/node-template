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
