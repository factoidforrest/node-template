

bcrypt = require("bcrypt")

module.exports = {

  attributes: {
  	

  	token: 'string',
    tokenSecret: 'string',
    password: 'string'
    
  }
  /*
  , beforeCreate: function (attrs, next) {
  	console.log('user before create called')
  	
	  bcrypt = require("bcrypt")
	  bcrypt.genSalt 10, (err, salt) ->
	    return next(err) if err
	    bcrypt.hash attrs.password, salt, (err, hash) ->
	      return next(err) if err
	      attrs.password = hash
	      next()
	   
	 }
	 */

}
