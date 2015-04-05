request = require('supertest');
setup = require('./libs/setup')
expect = require('chai').expect
userLib = require './libs/user'
braintree = require 'braintree'

userLib.createHooks()
login = userLib.login

previousBalance = null
testCard = null
program = null
newCardId = null
describe 'card', ->
	this.timeout 10000 
	
	before (done) -> 
		Program.refresh ->
			Program.fetchAll().then (programs) ->
				program = programs.first()
				User.where(email: 'light24bulbs@gmail.com').fetch().then((user) ->
					return user.related('cards').create({number:'2073183100123127', balance: 2, program_id: program.get('id')}).yield(user)#.save().then (card) ->
				).then (user) ->
						card = user.related('cards').models[0]
						Card.syncGroup [card], (err, cards) ->
							card = cards[0]
							console.log('associated to user', user)
							console.log('with  card', card)
							testCard = card
							done()




	it 'should create a card', (done) ->
		login {}, (session, token) ->
			session
			.post('/card/create').
			send({
				balance: 10
				nonce: braintree.Test.Nonces.Transactable
				token:token
				program_id: program.get('id')})
			.expect(200).end (err, res) ->
				newCardId = res.body.id
				console.log('got response creating card ', res.body)
				expect(res.body.balance).to.equal('10.00')

				if err?
					return done(err)
				Transaction.fetchAll({withRelated: ['user', 'card']}).then (transactions) ->
					console.log('transactions are:', transactions)
					expect(transactions.length).to.equal(1)
					console.log('transaction created: ', transactions.first())
					done(err)

	it 'should refill a card', (done) ->
		previousBalance = testCard.get('balance')
		login {}, (session, token) ->
			session
			.post('/card/refill').
			send({
				id: testCard.get('id')
				amount: 10
				nonce: braintree.Test.Nonces.Transactable
				token:token})
			.expect(200).end (err, res) ->
				console.log('reponse when refilling card is: ', res.body)
				expect(Number(res.body.balance)).to.equal(previousBalance + 10)
				previousBalance = Number(res.body.balance)

				done(err)

	it 'should fail to refill a card', (done) ->

		login {}, (session, token) ->
			session
			.post('/card/refill').
			send({
				id: testCard.get('id')
				amount: 2077.98
				nonce: braintree.Test.Nonces.Transactable
				token:token})
			.expect(400).end (err, res) ->
				console.log('reponse when failing to refill card is: ', res.body)
				Card.forge(id:testCard.get('id')).fetch().then (updatedCard)->
					expect(Number(updatedCard.get('balance'))).to.equal(previousBalance)
					
					done(err)

	it 'should list two cards for the logged in user', (done) ->
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

	it 'should import a card through the MGC api', (done) ->
		validNumber = '2073183109657266'
		login {}, (session, token) ->
			session
			.post('/card/import').
			send({
				card_number: validNumber, 
				token:token})
			.expect(200).end (err, res) ->
				console.log 'response when trying to import valid card is:', res.body
				#res.body.card_number.should.equal validNumber
				#console.log('got api logged in test response of:', res)
				done err
				return
			return
		return

	it 'shouldnt add duplicate card', (done) ->
		validNumber = '2073183100123127'
		login {}, (session, token) ->
			session.post('/card/import')
			.send({card_number: validNumber, token:token})
			.expect(400)
			.end (err, res) ->
				expect(res.body.name).to.equal('dupCard')
				console.log 'response when trying to import duplicate card is:', res.body
				#res.body.card_number.should.equal(validNumber);
				#console.log('got api logged in test response of:', res)
				done err
				return
			return
		return
	it 'should reject invalid card number through the MGC api', (done) ->
		login {}, (session, token) ->
			session.post('/card/import')
			.send({card_number: '12345678', token:token})
			.expect(400)
			.end (err, res) ->
				console.log 'response when trying to import card that doesnt exist is:', res.body
				expect(res.body.name).to.equal('TCCErr')
				#console.log('got api logged in test response of:', res)
				done err
				return
			return
		return


	it 'should sync a card', (done) ->
		Card.forge(number:'2073183100123127').fetch().then (card) ->
			card.TCCSync (err, card) ->
				console.log('synced card is: ', card)
				done()

		
	it 'should sync a card group', (done) -> 
		Card.forge(number:'2073183100123127').fetch().then (card) ->
			Card.syncGroup [card], (err, cards) ->
				console.log('synced cards: ', cards)
				done(err)
		
	it 'should void a card', (done) ->
		Card.forge(id: newCardId).fetch().then (card) ->
			card.TCCSync (err, card) ->
				console.log('fetched card to void: ', card.attributes)
				card.void (err) ->
					return done(err) if err?
					card.TCCSync (err, card) ->
						expect(card.get('status')).to.equal('void')
						expect(card.get('balance')).to.equal(0)
						console.log('card after syncing: ', card)
						done(err)

	it 'should fail to purchase a card with a failing payment', (done) ->
		login {}, (session, token) ->
			session
			.post('/card/create').
			send({
				balance: 2077.98
				nonce: braintree.Test.Nonces.Transactable
				token:token
				program_id: program.get('id')})
			.expect(400).end (err, res) ->
				console.log('failing card purchase response: ', res.body)
				done(err)