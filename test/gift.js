

require('./lift')

var expect = require('chai').expect
var request = require('supertest')
require('./create_user').createUser({})

var getUser = require('./create_user').getUser
var login = require('./login')



describe('gift cards gifting', function(){
	
		it('should buy a gift card to get things set up', function(done){
			login({},function(session){
				session
				.post('/giftcard/buy')
		    .send({amount: '1'})
		    .expect(200)
		    .end(function(err, res){
		    	//console.log('got api logged in test response of:', res)
		    	done(err);
		    });

		
		})
	});

	it('should have one gift card in the user', function(done){
		getUser(function(err, user){
			GiftCard.find({ownerId: user.id}, function(err, cards){
				console.log('err:', err)
				expect(cards.length).to.equal(1);
			})
		})
	})

});