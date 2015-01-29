/**
 * UserController
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


//USER MUST BE LOGGED IN TO USE THIS API, SEE CONFIG/POLICIES

module.exports = {


    update : function(req, res) {
        User.findOne({
            id : req.user.id
        }).done(function(err, profile) {

            console.log('hi profile is2', profile);
            if(!profile) {
                return res.send(409, {error : 'No User Found'});
            }

            profile.save(function(err, saved){
                    // Error handling
                    if (err) {
                        return res.send(409, {error : err.message});
                    }
                    profile.save(function() {
                        return res.json(saved);
                    });
              });
        });
    }
  
};
