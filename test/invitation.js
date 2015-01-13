

var expect = require('chai').expect

require('./libs/lift')
require('./libs/create_user').createUser({})

var getUser = require('./libs/create_user').getUser

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
		this.timeout(10000);
		getUser(function(err, sender){
			Invitation.invite('light24bulbs+invitation@gmail.com', sender, function(err, invitation){
				console.log('err is', err)
				console.log('invite is ', invitation)
				expect(err).to.equal(undefined)
				User.findOne({id: invitation.sender_id}, function(err, senderInDB){
					console.log('sender is ', senderInDB)
					expect(JSON.stringify(senderInDB)).to.equal(JSON.stringify(sender));
				})
				done();
			}) 
		})
	})






})