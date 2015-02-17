
request = require('supertest');
setup = require('./libs/setup')
expect = require('chai').expect
userLib = require('./libs/user')

describe 'Meals', ->
	it 'should create a meal and return a token', (done) ->
		session = request.agent(app)
		session
		.post('/meal/create').send(
			pos_secret:'123abc'
			meal: 
				balance: 5.52, 
				restaurant_id: 1, 
				items: {test1:'test1', test2: {nested1: 'nested1', nested2: 'nested2'}}
		
		).expect(200)
		.end (err, res) ->
			console.log('created meal with response', res.body)
			key = res.body.key
			new Meal().fetch().then (meal) ->
				console.log('retreived meal from database with attributes ', meal.attributes)
				expect(meal.get('key')).to.equal(key)
				done(err)

	it 'shouldnt create a meal if the POS key is wrong', (done) ->
		session = request.agent(app)
		session
		.post('/meal/create').send(
			pos_secret:'wrongcode'
			meal: 
				balance: 5.52, 
				restaurant_id: 1, 
				items: {test1:'test1', test2: {nested1: 'nested1', nested2: 'nested2'}}
		
		).expect(403)
		.end (err, res) ->
			console.log('created meal with response', res.body)
			done(err)

