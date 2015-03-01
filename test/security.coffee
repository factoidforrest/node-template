request = require('supertest');
setup = require('./libs/setup')
expect = require('chai').expect
async = require('async')

session = request.agent(app)
console.log('app is ', app)
describe 'security', ()->
	it 'should rate limit', (done) ->
		done()