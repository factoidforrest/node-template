app = require('../server')
request = require('supertest');
setup = require('./libs/setup')
expect = require('chai').expect
moment = require('moment')
userLib = require './libs/user'

userLib.createHooks()

describe 'tokens', ()->
	it 'should create', (done) ->
		Token.forge().save().then (token) ->
			console.log('token:', token)
			expect(token).to.exist
			done()

	it 'should expire properly', (done)->
		Token.fetchAll().then (tokens) ->
			token = tokens.models[0]
			expired = token.expired(1, 'days')
			console.log 'new token is expired?', expired
			expect(expired).to.equal(false)

			#now fake an old token
			age = moment().subtract(2, 'days').toDate()
			token.set('createdAt', age)

			expired = token.expired(1, 'days')
			console.log 'old token is expired?', expired
			expect(expired).to.equal(true)

			done()

	it 'should associate to a user', (done)->
		userLib.getUser().then((user) ->
			console.log('fetched user ', user)
			user.related('tokens').create().yield(user)
		).then (user) ->
			console.log('user after relation ', user)
			token = user.related('tokens').models[0].attributes
			console.log('with related token ', token)
			expect(user.related('tokens').length).to.equal(1)
			done()