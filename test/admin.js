var expect = require('chai').expect

require('./lift')
var login = require('./login')
require('./create_user').createUser({admin: true});
require('./create_user').createUser({email: 'light24bulbs+deactivate@gmail.com'});

var getUser = require('./create_user').getUser
var request = require('supertest');


describe('admin', function(){
	it('should deactivate other users', function(done){
		login(function(session){
			User.find({email: 'light24bulbs+deactivate@gmail.com'}, function(err, user){
				session
				.post('/admin/deactivateuser')
				.send({email: user.email})
	      .expect(200)
	      .end(function(err, res){
	      	console.log('deactivated user with response:', res.body)
	      	//console.log('got api logged in test response of:', res)
	      	done(err);
	      });
			});
		});
	});
});