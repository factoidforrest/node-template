

bcrypt = require("bcrypt-nodejs")

module.exports = {

  attributes: {
  	

  	token: 'string',
    tokenSecret: 'string',
    password: 'string',
    email: 'string'
    
  }
  
  ,beforeCreate: function (attrs, next) {
		next();
	}
	,afterCreate: function(attrs, next){
		next();
	}
	 

}
