/**
 * Token
 *
 * @module      :: Model
 * @description :: A short summary of how this model works and what it represents.
 * @docs		:: http://sailsjs.org/#!documentation/models
 */
//var moment = require('moment');


module.exports = {

  attributes: {
  	key: 'string',

  	/* e.g.
  	nickname: 'string'
  	*/
    
  },
  beforeCreate:function(attrs, next){
  	require('crypto').randomBytes(48, function(ex, buf) {
      attrs.key = buf.toString('hex');
      next();
    });
  }

};
