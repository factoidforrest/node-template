###
 * User
 *
 * @module      :: Model
 * @description :: A short summary of how this model works and what it represents.
 * @docs		:: http://sailsjs.org/#!documentation/models
 */
###

bcrypt = require("bcrypt")

module.exports = {

  attributes: {
  	

  	token: 'string',
    tokenSecret: 'string'
    password: 'string'
    
  }

  beforeCreate: (attrs, next) ->
    ###
	  bcrypt.genSalt 10, (err, salt) ->
	    return next(err)  if err
	    bcrypt.hash attrs.password, salt, (err, hash) ->
	      return next(err)  if err
	      attrs.password = hash
	      next()
    ###

}