

bcrypt = require("bcrypt")

module.exports = {

  attributes: {
  	

  	token: 'string',
    tokenSecret: 'string',
    password: 'string'
    
  }
  
  , beforeCreate: function (attrs, next) {
  	console.log('user before create called and the attributes are')
  	console.log(attrs)
	  //bcrypt = require("bcrypt")
	  if (attrs.strategy === 'local'){
		  bcrypt.genSalt(10, function (err, salt) {
		    return next(err) if err
		    bcrypt.hash(attrs.password, salt, function (err, hash) {
		      return next(err) if err
		      attrs.password = hash
		      next();
		    });

		  });
		} else {
			next();
	 	}
	}
	 

}
