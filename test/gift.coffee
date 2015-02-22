request = require('supertest');
setup = require('./libs/setup')
expect = require('chai').expect
userLib = require './libs/user'

userLib.createHooks()
login = userLib.login

testCard = null

describe 'gift', ->
	before (done) -> 
		User.where(email: 'light24bulbs@gmail.com').fetch().then((user) ->

			return user.related('cards').create({number:'2073183104321893', balance: 2}).yield(user)#.save().then (card) ->
		).then (user) ->

				console.log('associated to user', user)
				console.log('the card', user.related('cards').models[0])
				testCard = user.related('cards').models[0]
				#testCard = card
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
				Gift.forge({to_email:'light24bulbs+gifted@gmail.com'}).fetch({withRelated: ['from', 'card']}).then (gift) ->
					console.log('the saved gift is ', gift)
					expect(gift.related('from').get('email')).to.equal('light24bulbs@gmail.com')
					expect(gift.related('card').get('balance')).to.equal(1)
					done(err)

	it 'should revoke', (done) ->
		Gift.forge({to_email:'light24bulbs+gifted@gmail.com'}).fetch({withRelated: ['card']}).then (gift) ->
			gift.revoke ->
				console.log('revoked gift is ', gift)
				console.log('refunded gift is ', gift.related('card'))
				gift.get('status')
				done()


		###
		login {}, (session, token) ->
			console.log('logged in, now attempting to list cards')
			session
			.post('/card/list')
			.send(
				token:token
			)
			.expect(200)
			.end (err, res) ->
				console.log 'response when listing cards is:', res.body
				
				#console.log('got api logged in test response of:', res)
				done err
		###