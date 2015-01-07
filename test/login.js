
var request = require('supertest');

var savedSession;

module.exports = function(params, callback){
	if (!savedSession){
		var session = request.agent(sails.express.app);
		session
	  .post('/auth/local')
	  .send({ email: 'light24bulbs@gmail.com', password: 'secretpassword' })
	  .expect(200)
	  .end(function(err, res) {
	  	//console.log('login response:', res)
	  	console.log('logged in to new session with response', res.body)
	  	console.log('login err: ', err)
	  	savedSession = session;
	  	callback(session)
	    // session will manage its own cookies
	    // res.redirects contains an Array of redirects
	  });
	} else {
		console.log('using saved session')
		callback(savedSession)
	}
}