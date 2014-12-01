

bcrypt = require("bcrypt-nodejs")

module.exports = {

  attributes: {
  	

  	token: 'string',
    tokenSecret: 'string',
    password: 'string',
    username: 'string',

    validPassword: function(password) {
    	console.log('checking password')
    	valid = bcrypt.compareSync(password, this.password)
    	console.log('correct password? : ', valid)
    	console.log('the password is', password)
    	return valid;
    }
    
  }
  
  , beforeCreate: function (attrs, next) {

  	console.log('user before create called and the attributes are')
  	console.log(attrs)
	  //bcrypt = require("bcrypt")
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
