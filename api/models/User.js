

bcrypt = require("bcrypt-nodejs")

module.exports = {

  attributes: {
  	

  	token: 'string',
    tokenSecret: 'string',
    password: 'string',
    email: {
      type: 'email', // Email type will get validated by the ORM
      index: true
    },

    validPassword: function(password) {
      console.log('checking password')
      //would be more efficient to do this async, can figure that out once load becomes a problem
      valid = bcrypt.compareSync(password, this.password)
      console.log('correct password? : ', valid)
      return valid;
    },
    setPassword: function(password, next){
      var self = this;
      bcrypt.hash(password, null, null, function (err, hash) {
        if (err) return next(err);
        self.password = hash;
        next();
      });
    }
    
  }
  
  , beforeCreate: function (attrs, next) {

    console.log('user before create called and the attributes are')
    console.log(attrs)
    //bcrypt = require("bcrypt")
    //User.findByEmail(attrs.email).done(function(err, user){
    //  console.log('found users matching email: ', user)
    //});
    if (typeof(attrs.password) !== 'undefined'){//(attrs.strategy === 'local'){
      console.log("converting password to hash");
      bcrypt.hash(attrs.password, null, null, function (err, hash) {
        if (err) return next(err);
        attrs.password = hash;
        delete(attrs.passwordConfirmation);
        next();
      });

    } else {
      next();
    }
  }
	,afterCreate: function(attrs, next){
		next();
	}
	 

}
