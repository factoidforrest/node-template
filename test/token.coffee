app = require('../server')
request = require('supertest');
setup = require('./libs/setup')
expect = require('chai').expect

describe 'tokens', ()->
	it 'should create', (done) ->
		Token.create().then (token) ->
			console.log('token:', token)
			done()