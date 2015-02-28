require './libs/setup'
expect = require('chai').expect
userLib = require './libs/user'
#userLib.createHooks {}
request = require('supertest')
session = request.agent(app)
braintree = require 'braintree'
Payment = require '../server/services/payment'

describe 'payment', () ->
	this.timeout(15000)
	it 'should get client token', (done) ->
		session
		.post('/payment/clienttoken')
		.send({})
		.expect(200).end (err, res) ->
			console.log('client token response: ', res.body)
			done(err)

	it 'should transact', (done) ->
		Payment.authorize 10, braintree.Test.Nonces.Transactable, (err, result) ->
			console.log('Authorization responded with err, ', err, ' and result: ', result)
			if err?
				return done(err)

			Payment.settle result.transaction, (err, settlement) ->
				console.log('settlement responded with err: ', err, ' and settlement ', settlement)
				done(err)