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
			User.findOne({email: 'light24bulbs+deactivate@gmail.com'}, function(err, user){
				console.log('!!!!!!!!!! found user:', user)
				session
				.post('/admin/deactivateuser')
				.send({email: user.email, test: 'test'})
	      .expect(200)
	      .end(function(err, res){
	      	console.log('deactivated user with response:', res.body)
	      	User.findOne({email: 'light24bulbs+deactivate@gmail.com'}, function(err, deactivated){
	      		expect(deactivated.deactivated).to.equal(true)
	      		done(err);
	      	});
	      	//console.log('got api logged in test response of:', res)
	      	
	      });
			});
		});
	});
});