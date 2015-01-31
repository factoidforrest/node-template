var objectAssign = require('object-assign');

var registeredDestroyHook = false;

module.exports.createUser = function(params){

  
  before(function(done){
    module.exports.manuallyCreateUser(params, done)
  });

  if (!registeredDestroyHook){
    registeredDestroyHook = true;
    after(function(done){
      User.destroy({}, function() {
        console.log('destroyed all users')
        done();
      })
    })
  }
}

module.exports.manuallyCreateUser = function(attrs, done){
  var userProperties = {
      //if you change this be sure to change in the login.js file as well.  
      email: 'light24bulbs@gmail.com',
      last_name: 'testLast',
      full_name: 'testFirst testLast',
      provider: 'local',
      first_name: 'testFirst'
    }
  objectAssign(userProperties, attrs);

  User.create(userProperties).done(function(err, user){
    
    user.token = null;
    //need to do this in it's own step so it doesn't trigger password confirmation via email
    user.setPassword('secretpassword',function(){
      user.save(function(err,user){
        //console.log('created user for testing:', user)
        if (err) return done(err);
        done();
      });
    });
    
  });
}

module.exports.manuallyDestroyUser = function(done){
  User.destroy({}, function() {
    console.log('destroyed all users')
    done();
  })
}


module.exports.getUser = function getUser(cb){
  User.findOne({email: 'light24bulbs@gmail.com'}).exec(cb);
}

/*
module.exports.getUser = function getUser(params, cb){

  User.findOne({first_name: 'testFirst'}).exec(function(err, user){
    if(JSON.stringify(params) !== JSON.stringify({})) {
      return cb(err, user)
    } else {
      //modify the user using the params, save the user, and return it
    }

  });
}

*/