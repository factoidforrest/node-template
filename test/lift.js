/*
   Global before() and after() launcher for Sails application
   to run tests like Controller and Models test
*/

var should = require('chai').should()
var request = require('supertest')



before(function(done) {
  // Lift Sails and store the app reference
  require('sails').lift({

    // turn down the log level so we can view the test results
    log: {
      level: 'error'
    },
    //port: 5000,
    //apiRoot : "https://localhost:5000/",
    //assetRoot : "https://localhost:5000/",
    connections: {
      mongodb: {
        database: 'mobile-gift-card-test'
      }
    },

  }, function(err, sails) {
       // export properties for upcoming tests with supertest.js
       sails.localAppURL = localAppURL = ( sails.usingSSL ? 'https' : 'http' ) + '://' + sails.config.host + ':' + sails.config.port + '';
       // save reference for teardown function
       console.log('lifted sails for testing')

       done(err);
     });

});

// After Function
after(function(done) {
  sails.lower(done);
});

describe('account management', function(){
  beforeEach(function(done){
    User.create({
      email: 'light24bulbs@gmail.com',
      last_name: 'testLast',
      full_name: 'testFirst testLast',
      provider: 'local',
      first_name: 'testFirst'
    }).done(function(err, user){
      
      user.token = null;
      user.setPassword('secretpassword',function(){
        user.save(function(err,user){
          console.log('created user for testing:', user)
          if (err) return done(err);
          done();
        });
      });
      
    });
  });

  afterEach(function(done){
    User.destroy({}, function() {
      console.log('destroyed all users')
      done();
    })
  })

 

  describe('password', function(){
    it('should be correct', function(done){
      getUser(function(err, user){
        user.validPassword('secretpassword').should.equal(true);
        user.validPassword('secretpasswordwrong').should.equal(false);
        done();
      })
    })

    it('should send password reset email', function(done){
      this.timeout(10000);
      getUser(function(err, user){
        var query = request.agent(sails.express.app);
        query
          .post('/auth/sendresetemail')
          .send({email:user.email})
          .expect(200)
          .end(function(err, res){
            //reload the user.  Waterline sucks
            if (err) console.log('request err is ', err)
            done(err)
          });
      })
      
    });
    it('should reset to new value', function(done){
      getUser(function(err, user){
        Token.create({user_id: user.id}, function(err, token){
          var query = request.agent(sails.express.app);
          query
            .post('/auth/resetpassword')
            .send({token: token.key, password: 'newsecretpassword' })
            .expect(200)
            .end(function(err, res){
              //reload the user.  Waterline sucks
              if (err) return console.log('err is ', err)
              getUser(function(err, user){
                user.validPassword('secretpassword').should.equal(false);
                user.validPassword('newsecretpassword').should.equal(true);
                done(err);
              });
            });
        });
      });
      
    })
  })
})


function getUser(cb){
  User.findOne({first_name: 'testFirst'}).exec(cb);
}