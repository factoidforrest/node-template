request = require('supertest');
setup = require('./libs/setup')
expect = require('chai').expect
userLib = require './libs/user'

userLib.createHooks()
login = userLib.login

testCard = null
previousCardBalance = null
describe 'gift', ->
	this.timeout(10000)

	before (done) -> 
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
		this.timeout 15000
		userLib.getUser().then (from) ->

			Gift.send {
				email: 'light24bulbs+gifted@gmail.com'
				card: testCard.get('id')
				balance: 1
			}, from, (err) ->
				console.log('sent gift with error: ', err)
				return done(err) if err?
				Gift.forge({to_email:'light24bulbs+gifted@gmail.com'}).fetch({withRelated: ['from', 'card']}).then (gift) ->
					console.log('the saved gift is ', gift)
					expect(gift.related('from').get('email')).to.equal('light24bulbs@gmail.com')
					expect(gift.related('card').get('balance')).to.equal(previousCardBalance - 1)
					done(err)

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
				card: testCard.get('id')
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





