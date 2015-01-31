
app = require('../server')
request = require('supertest');

describe 'user', ->
	it 'sign up', (done) ->
		session = request.agent(app)
		session.post("/auth/register").send(
			email: "light24bulbs@gmail.com"
			password: "secretpassword"
			passwordConfirmation: 'secretpassword'
		).expect(200).end (err, res) ->
			
			#console.log('login response:', res)
			console.log "logged in to new session with response", res.body
			console.log "login err: ", err
			done(err)