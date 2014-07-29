/**
 * AuthController
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

var passport = require('passport');

module.exports = {

    google : function (req, res) {
        var options = { failureRedirect: '/login',
            scope:['https://www.googleapis.com/auth/plus.login','https://www.googleapis.com/auth/userinfo.profile','https://www.googleapis.com/auth/userinfo.email', 'https://www.googleapis.com/auth/gmail.modify'],
            accessType: 'offline',
            state: 'profile'
        };
        passport.authenticate('google',options,
            function (err, user) {
                req.logIn(user, function (err) {
                    if (err) {
                        console.log(err);
                        res.view('500');
                        return;
                    }


                    res.redirect('http://localhost:9000/#/cards');
                    return;
                });
            })(req, res);
    },
    logout : function(req, res) {
        req.logout();
        res.redirect('http://localhost:9000/');
    },




/**
   * Overrides for the settings in `config/controllers.js`
   * (specific to AuthController)
   */
  _config: {}

  
};
