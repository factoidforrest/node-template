
require './libs/setup'
should = require('chai').should()
userLib = require './libs/user'
userLib.createHooks {}
request = require('supertest')
tcc = require '../server/services/tcc'

describe 'TCC API', ->

	@timeout 15000

	it 'should create a new card using svAlloc', (done) ->
		tcc.createCard(10, '149').then((card) ->
			console.log 'new card created:', card
			done()
			return
		).fail (err) ->
			console.log 'card creation failed with error:', err
			done err
			return
		return

	it 'should query card data from tcc', (done) ->
		cardNumber = '2073183100123127'
		tcc.getTCCInquiry(cardNumber).then((tcc_card) ->
			console.log 'got card: ', tcc_card
			done()
			return
		).fail (err) ->
			done err
			return
		return

	

# ---
# generated by js2coffee 2.0.1