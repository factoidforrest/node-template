/**
 * Meal
 *
 * @module      :: Model
 * @description :: A short summary of how this model works and what it represents.
 * @docs		:: http://sailsjs.org/#!documentation/models
 */

module.exports = {

  attributes: {
  	
  	/* e.g.
  	nickname: 'string'
  	*/
    
  }
  , beforeCreate: function (attrs, next) {
  	 require('crypto').randomBytes(4, function(ex, buf) {
      attrs.key = buf.toString('hex');
      next();
    });
  }

};
