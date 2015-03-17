
request = require('supertest');
setup = require('./libs/setup')
expect = require('chai').expect
userLib = require('./libs/user')
userLib.createHooks()

session = request.agent(app)
mealKey = null
cardId = null

describe 'Meals', ->
	before (done) -> 
		User.where(email: 'light24bulbs@gmail.com').fetch().then((user) ->
			#this card won't sync unless we change the number to something valid
			return user.related('cards').create({number: '2073183100123127', program_id: '183', balance: 2}).yield(user)#.save().then (card) ->
		).then (user) ->
			console.log('created card', user.related('cards').first())
			cardId = user.related('cards').first().get('id')
			done()

	it 'should create a meal and return a token', (done) ->
		session
		.post('/meal/create').send(
			pos_secret:'123abc'
			meal: 
				balance: 5.52, 
				program_id: 183, 
				items: {test1:'test1', test2: {nested1: 'nested1', nested2: 'nested2'}}
		
		).expect(200)
		.end (err, res) ->
			console.log('created meal with response', res.body)
			mealKey = key = res.body.key
			new Meal().fetch().then (meal) ->
				console.log('retreived meal from database with attributes ', meal.attributes)
				expect(meal.get('key')).to.equal(key)
				done(err)

	it 'shouldnt create a meal if the POS key is wrong', (done) ->
		session
		.post('/meal/create').send(
			pos_secret:'wrongcode'
			meal: 
				price: 5.52, 
				restaurant_id: 1, 
				items: {test1:'test1', test2: {nested1: 'nested1', nested2: 'nested2'}}
		
		).expect(403)
		.end (err, res) ->
			console.log('created meal with response', res.body)
			done(err)

	it 'should spend a card on the meal', (done) ->
		this.timeout 10000
		Card.fetchAll().then (cards) ->
			console.log('found existing cards ', cards)			
			console.log('test attempting to redeem card id: ', cardId)
			userLib.login {}, (session, token) ->
				session
				.post('/card/redeem').send(
					token: token
					meal_key: mealKey
					id: cardId
					amount: 1
				).expect(200)
				.end (err, res) ->
					if err?
						return done(err)
					console.log('redeemed card with response', res.body)
					console.log('meal transactions: ', res.body.meal.transactions)
					expect(res.body.meal.balance).to.equal(res.body.meal.price - 1)
					Card.fetchAll().then (cards) ->
						console.log('redeemed card in db is: ', cards.first())
						done(err)

	it 'should checkout the meal', (done) ->
		this.timeout 10000
		session
		.post('/meal/checkout').send(
			pos_secret:'123abc',
			key: mealKey
		).expect(200).end (err, res) ->

			console.log('checked out with response ', res.body)
			Meal.fetchAll(withRelated: 'transactions.card').then (meals) ->
				console.log 'meal in database is ', meals.first().toJSON()
				done(err)