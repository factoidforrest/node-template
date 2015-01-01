
require('./lift')
var should = require('chai').should()

describe('TCC API', function(){
	it('should create card', function(done){
		var cardNumber = '1234567'
		TCCProxy.getTCCInquiry(cardNumber).then(function(tcc_card) {
			console.log('got card: ', tcc_card)
			done();
		});
	})
})