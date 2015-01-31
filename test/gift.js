

require('./libs/lift')

var expect = require('chai').expect
var request = require('supertest')
var userUtil = require('./libs/create_user')
userUtil.createUser({})
userUtil.createUser({email:'light24bulbs+giftme@gmail.com'})
var getUser = userUtil.getUser
var login = require('./libs/login')



describe('gift cards gifting', function(){
	
		it('should buy a gift card to get things set up', function(done){
			this.timeout(15000)
			login({},function(session){
				session
				.post('/giftcard/buy')
		    .send({amount: '1'})
		    .expect(200)
		    .end(function(err, res){
		    	console.log('response when trying to buy card is:', res.body)
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
				done(err)
			})
		})
	})

	it('should gift to another user', function(done){
		getUser(function(err, user){
			console.log('got a card owner id of:', user.id)
			GiftCard.findOne({ownerId: user.id}, function(err, card){


				login({}, function(session){
					session
					.post('/giftcard/gift')
			    .send({email:'light24bulbs+giftme@gmail.com', id: card.id })
			    .expect(200)
			    .end(function(err, res){

			   		console.log("got response for gifting a card: ", res.body)
			    	GiftCardGift.findOne({giftRecipientEmail:'light24bulbs+giftme@gmail.com'}, function(err, gift){
			    		console.log('gift card gift is:', gift)
			    		expect(gift).to.exist;
			    		done(err)
			    	})
			    	//console.log('got api logged in test response of:', res)
			    });


			  });

			});
		});
	});


});