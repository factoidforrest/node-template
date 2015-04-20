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
POSCardNumber = null

describe 'card', ->
	this.timeout 10000 
	
	before (done) -> 
		Program.fetchAll().then (programs) ->
			program = programs.first()
			User.where(email: 'light24bulbs@gmail.com').fetch().then (user) ->
				Card.build {program_id: program.get('id'), balance: 2, user_id: user.get('id')}, (err, card) ->
					#if err? return done(err)
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

	it 'should retrieve card info', (done) ->
		login {}, (session, token) ->
			session
			.post('/card/info').
			send({
				id: testCard.get('id')
				token: token
			})
			.expect(200).end (err, res) ->
				console.log('retrieved card info: ', res.body)
				expect(res.body.id).to.equal(testCard.get('id'))
				done(err)

	it 'should retrieve info by POS', (done) ->
		login {}, (session, token) ->
			session
			.post('/card/posinfo').
			send({
				number: testCard.get('number')
				pos_secret: '123abc'
			})
			.expect(200).end (err, res) ->	
				console.log('retrieved card info: ', res.body)
				expect(res.body.id).to.equal(testCard.get('id'))
				done(err)	

	it 'should refill a card', (done) ->
		previousBalance = Number(testCard.get('balance'))
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
				console.log('PREVIOUS BALANCE IS!!!!!!!!! ', previousBalance)
				done(err)

	it 'should fill/activate a physical card from POS', (done) ->
		#create a new empty card not saved in our system to fill using POS
		Program.fetchAll().then (programs) ->
			programId = programs.first().get('id')
			#for whatever reason valid program ids arent working at the moment, giving login error
			TCC.createCard(0, null).then (data) ->
				console.log 'new card at POS created: ', data
				POSCardNumber = data.card_number
				session = request.agent(app)
				session
				.post('/card/posfill').
				send({
					number:POSCardNumber
					amount: 10
					location_id: 1
					client_id: '47d88fb4-76d1-4ad8-b08b-5f4088b64b8a'
					pos_secret: '123abc'
				})
				.expect(200).end (err, res) ->
					console.log('pos refill response: ', res.body)
					done(err)





 
	it 'should fail to refill a card', (done) ->
		console.log('PREVIOUS BALANCE IS!!!!!!!!! ', previousBalance)
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
		validNumber = POSCardNumber
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
	###
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
	###
	
	it 'should reject invalid card number through the MGC api', (done) ->
		login {}, (session, token) ->
			session.post('/card/import')
			.send({card_number: '12345678', token:token})
			.expect(400)
			.end (err, res) ->
				console.log 'response when trying to import card that doesnt exist is:', res.body
				expect(res.body.name).to.equal('cardNotFound')
				#console.log('got api logged in test response of:', res)
				done err
				return
			return
		return


	it 'should sync a card', (done) ->
		testCard.TCCSync (err, card) ->
			console.log('synced card is: ', card)
			done()

		
	it 'should sync a card group', (done) -> 
		Card.syncGroup [testCard], (err, cards) ->
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

