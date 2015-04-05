request = require('supertest');
setup = require('./libs/setup')
expect = require('chai').expect
userLib = require './libs/user'

userLib.createHooks()
login = userLib.login

testCard = null
testGift = null
previousCardBalance = null
describe 'gift', ->
	this.timeout(10000)

	before (done) -> 
		userLib.createUser {email: 'light24bulbs+gifted@gmail.com'}, ->
			User.where(email: 'light24bulbs@gmail.com').fetch().then((user) ->
				return user.related('cards').create({number:'2073183100123127', balance: 2}).yield(user)#.save().then (card) ->
			).then (user) ->
				testCard = user.related('cards').models[0]
				Card.syncGroup [testCard], (err, cards) ->
					card = cards[0]
					console.log('synced card', card.attributes)
					previousCardBalance = card.get('balance')
					done()


	it 'should send a gift', (done) ->
		userLib.login {}, (session, token) ->
			session
			.post("/gift/send").send(
				token: token
				card_id: testCard.get('id')
				email: 'light24bulbs+gifted@gmail.com'
				amount: 1
			).expect(200).end (err, res) ->
				console.log('response sending gift ', res.body)
				return done(err) if err?
				expect(res.body.balance).to.equal(1)
				Gift.forge(id: res.body.id).fetch({withRelated: ['card', 'from']}).then (gift) ->
					testGift = gift
					console.log('the saved gift is ', gift)
					expect(gift.related('from').get('email')).to.equal('light24bulbs@gmail.com')
					expect(gift.related('card').get('balance')).to.equal(previousCardBalance - 1)
					#previousCardBalance = gift.related('card').get('balance')
					done()

	###
	it 'should send a gift', (done) ->
		this.timeout 15000
		userLib.getUser().then (from) ->

			Gift.send {
				email: 'light24bulbs+gifted@gmail.com'
				card: testCard.get('id')
				balance: 1
			}, from, (err, gift) ->
				console.log('sent gift with error: ', err)
				return done(err) if err?
				testGift = gift
				Gift.forge({to_email:'light24bulbs+gifted@gmail.com'}).fetch({withRelated: ['from', 'card']}).then (gift) ->
					console.log('the saved gift is ', gift)
					expect(gift.related('from').get('email')).to.equal('light24bulbs@gmail.com')
					expect(gift.related('card').get('balance')).to.equal(previousCardBalance - 1)
					done(err)
	###

	it 'should list the gift', (done) ->
		login {}, (session, token) ->
			console.log('gift list login complete, about to send request')
			session
			.post("/gift/list").send(
				token: token
			).expect(200).end (err, res) ->
				console.log('gift list response:', res.body)
				expect(res.body.outgoing.length).to.equal(1)
				console.log('outgoing attached user:', res.body.outgoing[0].from)
				console.log('outgoing attached card:', res.body.outgoing[0].card)
				expect(res.body.incoming.length).to.equal(0)
				done(err)



	###
	it 'should revoke through model', (done) ->
		Gift.forge({to_email:'light24bulbs+gifted@gmail.com'}).fetch({withRelated: ['card']}).then (gift) ->
			gift.revoke ->
				console.log('revoked gift is ', gift.attributes)
				console.log('refunded gift is ', gift.related('card').attributes)
				expect(gift.get('status')).to.equal('revoked')
				expect(gift.get('balance')).to.equal(previousCardBalance)
				done()
	###

	it 'should revoke through api', (done) ->
		login {}, (session, token) ->
			session
			.post("/gift/revoke").send(
				token: token
				gift_id: testGift.get('id')
			).expect(200).end (err, res) ->
				console.log('gift revoke response:', res.body)
				return done(err) if err?
				Gift.forge({to_email:'light24bulbs+gifted@gmail.com'}).fetch({withRelated: ['card']}).then (gift) ->
					card = gift.related('card')
					console.log('revoked gift is ', gift.attributes)
					console.log('refunded gift is ', gift.related('card').attributes)
					expect(gift.get('status')).to.equal('revoked')
					expect(card.get('balance')).to.equal(previousCardBalance)
					done(err)

	it 'should send another gift', (done) ->
		userLib.login {}, (session, token) ->
			session
			.post("/gift/send").send(
				token: token
				card_id: testCard.get('id')
				email: 'light24bulbs+gifted@gmail.com'
				amount: 1
			).expect(200).end (err, res) ->
				console.log('response sending gift ', res.body)
				return done(err) if err?
				expect(res.body.balance).to.equal(1)
				Gift.forge({to_email:'light24bulbs+gifted@gmail.com', status: 'pending'}).fetch({withRelated: ['from', 'card']}).then (gift) ->
					console.log('the saved gift is ', gift)
					testGift = gift
					expect(gift.related('from').get('email')).to.equal('light24bulbs@gmail.com')
					expect(gift.related('card').get('balance')).to.equal(previousCardBalance - 1)
					done(err)


	it 'should accept a gift', (done) ->
		console.log('attempting to accept this gift: ', testGift.attributes)
		userLib.login {email:'light24bulbs+gifted@gmail.com', password: 'secretpassword'}, (session, token) ->
			session
			.post("/gift/accept").send(
				token: token
				gift_id: testGift.get('id')
			).expect(200).end (err, res) ->
				console.log('accept response:', res.body)
				expect(res.body.balance).to.equal('1.00')
				Gift.forge(id: testGift.get('id')).fetch().then (gift)->
					console.log('gift attributes: ', gift.attributes)
					done(err)







