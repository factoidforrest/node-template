/**
 * AdminController
 *
 * @module      :: Controller
 * @description	:: A set of functions called `actions`.
 *
 *                 Actions contain code telling Sails how to respond to a certain type of request.
 *                 (i.e. do stuff, then send some JSON, show an HTML page, or redirect to another URL)
 *
 *                 You can configure the blueprint URLs which trigger these actions (`config/controllers.js`)
 *                 and/or override them with custom routes (`config/routes.js`)
 *
 *                 NOTE: The code you write here supports both HTTP and Socket.io automatically.
 *
 * @docs        :: http://sailsjs.org/#!documentation/controllers
 */

module.exports = {
    deactivateuser : function(req, res){
    	var email = req.params.email;
    	User.findOne({email: email}, function(err, user){
    		sails.info('found user to deactivate:', user)
    		if (typeof user === 'undefined') return res.send(500, {error:'No user with that email'});
    		user.deactivated = true;
    		user.save(function(err, user){
    			if (typeof user === 'undefined') return res.send(500, {error:'Error deactivating'});
    			res.json({status:'Success'})
    		})
    	})
    },
  


  /**
   * Overrides for the settings in `config/controllers.js`
   * (specific to AdminController)
   */
  _config: {}

  
};
