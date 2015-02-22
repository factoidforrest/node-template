request = require('supertest');
setup = require('./libs/setup')
expect = require('chai').expect
userLib = require './libs/user'

userLib.createHooks()
login = userLib.login

testCard = null

describe 'card', ->
	before (done) -> 
		User.where(email: 'light24bulbs@gmail.com').fetch().then((user) ->

			return user.related('cards').create({number:'2073183100123127', balance: 2}).yield(user)#.save().then (card) ->
		).then (user) ->

				console.log('associated to user', user)
				console.log('the card', user.related('cards').models[0])
				#testCard = card
				done()



	it 'should list one card for the logged in user', (done) ->
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
    validNumber = '2073183100123127'
    login {}, (session, token) ->
      session
      .post('/card/create').
      send({
        card_number: validNumber, 
        token:token})
      .expect(200).end (err, res) ->
        console.log 'response when trying to import valid card is:', res.body
        res.body.card_number.should.equal validNumber
        #console.log('got api logged in test response of:', res)
        done err
        return
      return
    return

  it 'shouldnt add duplicate card', (done) ->
    validNumber = '2073183100123127'
    login {}, (session, token) ->
      session.post('/card/create').send({card_number: validNumber, token:token}).expect(500).end (err, res) ->
        console.log 'response when trying to import duplicate card is:', res.body
        #res.body.card_number.should.equal(validNumber);
        #console.log('got api logged in test response of:', res)
        done err
        return
      return
    return
  it 'should reject invalid card number through the MGC api', (done) ->
    login {}, (session, token) ->
      session.post('/card/create').send({card_number: '12345678', token:token}).expect(500).end (err, res) ->
        console.log 'response when trying to import card that doesnt exist is:', res.body
        #console.log('got api logged in test response of:', res)
        done err
        return
      return
    return


  it 'should sync a card', (done) ->
    Card.forge(number:'2073183100123127').fetch().then (card) ->
      card.sync (err, card) ->
        console.log('synced card is: ', card)
        done()

    
  it 'should sync a card group', (done) -> 
    Card.forge(number:'2073183100123127').fetch().then (card) ->
      Card.syncGroup [card], (err, cards) ->
        console.log('synced cards: ', cards)
        done(err)
    


