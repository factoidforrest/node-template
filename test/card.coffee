app = require('../server')
request = require('supertest');
setup = require('./libs/setup')
expect = require('chai').expect
userLib = require './libs/user'

userLib.createHooks()

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

