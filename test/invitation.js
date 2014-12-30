

var expect = require('chai').expect

require('./lift')
var getUser = require('./create_user').getUser

describe('invitations', function(){
	it('shouldnt create for email which is already a user or invitation',function(done){
		getUser(function(err, sender){
			Invitation.invite('light24bulbs@gmail.com', sender, function(err){
				console.log('err is', err)
				expect(err).to.equal('User already exists')
				done();
			}) 
		})
	})
	it('should create', function(done){
		getUser(function(err, sender){
			Invitation.invite('light24bulbs+invitation@gmail.com', sender, function(err){
				console.log('err is', err)
				expect(err).to.equal(undefined)
				done();
			}) 
		})
	})






})