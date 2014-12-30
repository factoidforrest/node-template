beforeEach(function(done){
  User.create({
    email: 'light24bulbs@gmail.com',
    last_name: 'testLast',
    full_name: 'testFirst testLast',
    provider: 'local',
    first_name: 'testFirst'
  }).done(function(err, user){
    
    user.token = null;
    //need to do this in it's own step so it doesn't trigger password confirmation via email
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

module.exports.getUser = function getUser(cb){
  User.findOne({first_name: 'testFirst'}).exec(cb);
}