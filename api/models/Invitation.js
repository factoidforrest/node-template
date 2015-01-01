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
    	type: 'string',
    	index:true,
    	required: true
    },
    notify: function(done){
      Mail.invite(this.email, function(err){
        done(err);
      })
    }

    
  },

  invite: function(invited, sender, callback) {
  	User.findOne({email: invited}, function(err, existing){
      console.log('the type is', typeof(existing) !== 'undefined')
  		if (typeof(existing) !== 'undefined'){
  			return callback('User already exists');
  		}
      Invitation.create({email: invited, sender_id: sender.id}, function(err, invitation){
        if (err) return callback(err);
        invitation.notify(function(err){
          callback(err, invitation);
        });
        
      });
  		
		});

  }

};
