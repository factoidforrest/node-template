/**
 * Configuration
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
    variables: function(){
    	delete this.createdAt;
    	delete this.updatedAt;
    	delete this.id;
    	return this;
    }
  }

};
