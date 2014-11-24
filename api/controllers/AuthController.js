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
var FacebookStrategy = require('passport-facebook').Strategy;

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


                    var conf = sails.config;
//                    res.redirect('//app.mobilegiftcard.com/#/cards');
                    res.redirect(conf.apiRoot + '#/cards');
                    return;
                });
            })(req, res);
    },

    profile : function(req, res) {
        console.log('the request is ', req)
        User.findOne({id : req.user.id}).done(function(err, user) {
            if (err) {
                res.send(501);
            } else {
                res.json({
                    created_at: user.createdAt,
                    email: user.email,
                    fist_name: user.firstname,
                    id: user.id,
                    last_name: user.lastname,
                    full_name: user.name,
                    provider: user.provider,
                    uid: user.uid,
                    updated_at: user.updatedAt
                });
            }
        });
    },

    logout : function(req, res) {
        req.logout();
//        res.redirect('//app.mobilegiftcard.com/');
        res.redirect(sails.config.apiRoot);
    },




/**
   * Overrides for the settings in `config/controllers.js`
   * (specific to AuthController)
   */
  _config: {}

  
};
