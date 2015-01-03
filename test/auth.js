var expect = require('chai').expect

require('./lift')
var login = require('./login')
require('./create_user').createUser({})

var getUser = require('./create_user').getUser
var request = require('supertest');



describe('local auth', function(){
	it('should reject if not logged in', function(done){
		var session = request.agent(sails.express.app);
		session
		.post('/giftcard/find')
//            .send({token: token.key, password: 'newsecretpassword' })
      .expect(403)
      .end(function(err, res){
      	console.log('attempted unpriviledged action with response:', res.body)
      	//console.log('got api logged in test response of:', res)
      	done(err);
      });

	})
	it('should log in', function(done){
		login(function(session){
			session
			.post('/giftcard/find')
//            .send({token: token.key, password: 'newsecretpassword' })
      .expect(200)
      .end(function(err, res){
      	console.log('attempted action while signed in with response', res.body)
      	//console.log('got api logged in test response of:', res)
      	done(err);
      });
		})
	})


})