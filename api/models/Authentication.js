
bcrypt = require("bcrypt-nodejs")

module.exports = {

  attributes: {
  	

  	token: 'string',
    tokenSecret: 'string',
    password: 'string',
    email: 'string',

    validPassword: function(password) {
    	console.log('checking password')
    	//would be more efficient to do this async, can figure that out once load becomes a problem
    	valid = bcrypt.compareSync(password, this.password)
    	console.log('correct password? : ', valid)
    	console.log('the password is', password)
    	return valid;
    }
    
  }
  
  , beforeCreate: function (attrs, next) {

  	console.log('auth before create called and the attributes are')
  	console.log(attrs)
	  //bcrypt = require("bcrypt")
	  User.findByEmail(attrs.email).done(function(err, user){
	  	console.log('found users matching email: ', user)
	  });
	  if (attrs.strategy === 'local'){

	    bcrypt.hash(attrs.password, null, null, function (err, hash) {
	      if (err) return next(err);
	      attrs.password = hash;
	    	//delete attrs.passwordConfirmation;
	      next();
	    });

		} else {
			next();
	 	}
	}
	,afterCreate: function(attrs, next){
		//console.log('aftercreate callback called with attrs: ', attrs)
		next();
	}
	 

}
