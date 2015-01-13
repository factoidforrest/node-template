
require('./libs/lift')
var should = require('chai').should()

describe('TCC API', function(){
	it('should create card', function(done){
		var cardNumber = '2093555002667630'
		TCCProxy.getTCCInquiry(cardNumber).then(function(tcc_card) {
			console.log('got card: ', tcc_card)
			done();
		},
		function(err){
			throw err;
		});
	})
})