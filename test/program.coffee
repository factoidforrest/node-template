
request = require('supertest');
setup = require('./libs/setup')
expect = require('chai').expect
userLib = require('./libs/user')

tcc = require '../server/services/tcc'

describe 'programs', () ->
	it 'should get programs from tcc', (done) ->
		tcc.getPrograms (err, programs) ->
			if err?
				console.log('tcc error: ', err)
				return done(err)
			console.log('got programs from tcc')
			console.log(programs)
			done()

	it 'should refresh programs', (done) ->
		Program.refresh (err) ->
			console.log('refreshed programs')
			done()