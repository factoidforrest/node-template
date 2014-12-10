
bcrypt = require("bcrypt-nodejs")

module.exports = {

  attributes: {
  	

  	token: 'string',
    tokenSecret: 'string',
    email: 'string',

  }
  
  , beforeCreate: function (attrs, next) {
		next();
	}
	,afterCreate: function(attrs, next){
		//console.log('aftercreate callback called with attrs: ', attrs)
		next();
	}
	 

}

