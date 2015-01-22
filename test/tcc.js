
require('./libs/lift')
var should = require('chai').should()
var login = require('./libs/login')
require('./libs/create_user').createUser({})

var getUser = require('./libs/create_user').getUser
var request = require('supertest');


describe('TCC API', function(){

	after(function(done){
    GiftCard.destroy({}, function() {
      console.log('destroyed all gift cards')
      done();
    })
  })

	this.timeout(15000)
	it('should query card data from tcc', function(done){
		var cardNumber = '2093555002667630'
		TCCProxy.getTCCInquiry(cardNumber).then(function(tcc_card) {
			console.log('got card: ', tcc_card)
			done();
		})
		.fail(function(err){
			throw err;
		});
	})

	it('should import a card through the MGC api', function(done){
		this.timeout(15000);
		var validNumber = '2093555002667630'
		login({}, function(session){
			session
			.post('/giftcard/create')
	    .send({card_number: validNumber})
	    .expect(200)
	    .end(function(err, res){
	    	console.log('response when trying to import valid card is:', res.body)
	    	res.body.card_number.should.equal(validNumber);
	    	//console.log('got api logged in test response of:', res)
	    	done(err);
	    });
	  });
	})

	it('shouldnt add duplicate card', function(done){
		this.timeout(15000);
		var validNumber = '2093555002667630'
		login({}, function(session){
			session
			.post('/giftcard/create')
	    .send({card_number: validNumber})
	    .expect(500)
	    .end(function(err, res){
	    	console.log('response when trying to import duplicate card is:', res.body)
	    	//res.body.card_number.should.equal(validNumber);
	    	//console.log('got api logged in test response of:', res)
	    	done(err);
	    });
	  });
	})
	it('should reject invalid card number through the MGC api', function(done){
		this.timeout(15000);
		login({}, function(session){
			session
			.post('/giftcard/create')
	    .send({card_number: '12345678'})
	    .expect(500)
	    .end(function(err, res){
	    	console.log('response when trying to import card that doesnt exist is:', res.body)
	    	//console.log('got api logged in test response of:', res)
	    	done(err);
	    });
		})
	})
})