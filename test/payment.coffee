require './libs/setup'
expect = require('chai').expect
userLib = require './libs/user'
#userLib.createHooks {}
request = require('supertest')
session = request.agent(app)

describe 'payment', () ->
	it 'should get client token', (done) ->
		session
		.post('/payment/clienttoken')
		.send({})
		.expect(200).end (err, res) ->
			console.log('client token response: ', res.body)
			done(err)