require('./libs/lift')
var should = require('chai').should()
var request = require('supertest');

describe('Meals', function(){
	it('should create a meal and return a token', function(done){
		var session = request.agent(sails.express.app);
		session
	  .post('/meal/create')
	  .send({ test1:'test1', test2: 'test2' })
	  .expect(200)
	  .end(function(err, res) {
	  	//console.log('login response:', res)
	  	console.log('created meal with response', res.body);
	  	res.body.key.length.should.equal(8);
	  	done(err);
	    // session will manage its own cookies
	    // res.redirects contains an Array of redirects
	  });
	})
})