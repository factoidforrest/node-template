/*
   Global before() and after() launcher for Sails application
   to run tests like Controller and Models test
*/

var should = require('chai').should()
var request = require('supertest')
var moment = require('moment')

require('./libs/lift')
require('./libs/create_user').createUser({})
var getUser = require('./libs/create_user').getUser


describe('account management', function(){
  

 

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

    it('shouldnt reset for expired tokens', function(done){
      getUser(function(err, user){
        var TwoHoursAgo = moment().subtract(2,'hours').toDate()
        Token.create({user_id: user.id}, function(err, token){
          token.createdAt = TwoHoursAgo
          token.save(function(err, token){
            console.log('created token: ', token)
            var query = request.agent(sails.express.app);
            query
              .post('/auth/resetpassword')
              .send({token: token.key, password: 'newsecretpassword' })
              .expect(400)
              .end(function(err, res){
                //reload the user.  Waterline sucks
                if (err) return done(err)
                getUser(function(err, user){
                  user.validPassword('secretpassword').should.equal(true);
                  user.validPassword('newsecretpassword').should.equal(false);
                  console.log('got response: ', res)
                  done(err);

                });
              });

          })
          
        });
      });
    })

    it('should update the names', function(done){
      login({},function(session){
        session
        .post('/auth/update')
        .send({firstName: 'updatedname', lastName: 'updatedname'})
        .expect(200)
        .end(function(err, res){
          console.log('response when trying to update users names is:', res.body)
          //console.log('got api logged in test response of:', res)
          done(err);
        });
      });

    })
  })
})


