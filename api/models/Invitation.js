/**
 * Invitation
 *
 * @module      :: Model
 * @description :: A short summary of how this model works and what it represents.
 * @docs		:: http://sailsjs.org/#!documentation/models
 */

module.exports = {

  attributes: {
    email: {
      type: 'email', // Email type will get validated by the ORM
      index: true,
      required: true
    },
    sender_id: {
    	type: 'integer',
    	index:true,
    	required: true
    }
  	/* e.g.
  	nickname: 'string'
  	*/
    
  }

};
