request = require('supertest');
setup = require('./libs/setup')
expect = require('chai').expect
moment = require('moment')
userLib = require './libs/user'

userLib.createHooks()

key = null

describe 'tokens', ()->
	it 'should create', (done) ->
		Token.forge().save().then (token) ->
			console.log('token:', token)
			expect(token).to.exist
			done()

	it 'should expire properly', (done)->
		Token.fetchAll().then (tokens) ->
			console.log 'fetched tokens ', tokens.models
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
			key = user.related('tokens').models[0].get('key')
			console.log('got key')
			done()

	it 'should authenticate a request', (done) ->
		session = request.agent(app)
		session.post("/user/testtoken").send({
			token: key
		}).expect(200).end (err, res) ->
			
			#console.log('login response:', res)
			console.log('authenticated with token and got response:', res.body)
			done(err)

	it 'request should fail on a bad token', (done) ->
		session = request.agent(app)
		session.post("/user/testtoken").send({
			token: '12345asddoijb'
		}).expect(401).end (err, res) ->
			
			#console.log('login response:', res)
			console.log('authenticated with bad token and got response:', res.body)
			done(err)