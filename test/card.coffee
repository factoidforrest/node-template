app = require('../server')
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
			return user.related('cards').create({number:'1234abcd'}).yield(user)#.save().then (card) ->
		).then (user) ->

				console.log('associated to user', user)
				console.log('the card', user.related('cards').models[0])
				#testCard = card
				done()



	it 'should have one user', (done) ->
		done()

	it 'should import a card through the MGC api', (done) ->
    validNumber = '2073183100123127'
    login {}, (session) ->
      session.post('/card/create').send(card_number: validNumber).expect(200).end (err, res) ->
        console.log 'response when trying to import valid card is:', res.body
        res.body.card_number.should.equal validNumber
        #console.log('got api logged in test response of:', res)
        done err
        return
      return
    return

  it 'shouldnt add duplicate card', (done) ->
    validNumber = '2073183100123127'
    login {}, (session) ->
      session.post('/card/create').send(card_number: validNumber).expect(500).end (err, res) ->
        console.log 'response when trying to import duplicate card is:', res.body
        #res.body.card_number.should.equal(validNumber);
        #console.log('got api logged in test response of:', res)
        done err
        return
      return
    return
  it 'should reject invalid card number through the MGC api', (done) ->
    login {}, (session) ->
      session.post('/card/create').send(card_number: '12345678').expect(500).end (err, res) ->
        console.log 'response when trying to import card that doesnt exist is:', res.body
        #console.log('got api logged in test response of:', res)
        done err
        return
      return
    return
  return

