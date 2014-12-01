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
	
	facebook: function (req, res) {
		var options = { 
			failureRedirect: '/login'
		}

		passport.authenticate('facebook', options, 
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
	}

	,local: passport.authenticate('local', { successRedirect: '#/cards', failureRedirect: '/' })


	,profile : function(req, res) {
	   // console.log('the request is ', req)
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
	}

	,register: function(req, res) {
		console.log('registering user with params: ', req.body);
		params = req.body;
		//verify passwords match and are long enough 
		if (passwordValid(params, res)){
			User.findByUsername(req.body.username).done(function(err, usr){
				if (err) {
					res.send(500, { error: "DB Error" });
				} else if (usr.length > 0) {
					res.send(200, {
							success: false
							, errors: { username: "Username already taken" }
						});
				} else {
					params.strategy = 'local';
					//store the password so we can put it back in the req when bcrypt overwrites it in the user beforecreate
					var password = req.body.password;
					var user = User.create(params).done(function(error, user){
						if (error) {
							res.send(500, {error: "DB Error"});
						} else {
						  console.log('the user was saved as', user);
						  req.body.password = password;
							
						  passport.authenticate('local')(req, res, function () {
						  	console.log('authenticated new user')
                res.json({
									success: true,
									errors: {}
								});
            	});


						}
					
					});
				}
			});
		}
	}


	,logout : function(req, res) {
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



function passwordValid(params, res) {
	if (params.password !== params.passwordConfirmation) {
		console.log('passwords didnt match')
		res.send(200, {
			success:false
			,errors: {
				passwordConfirmation: "Passwords don't match"
			}})
		return false;
		//check password length
	} else if (params.password.length < 6) {
		console.log('password too short')
		res.send(200, {
			success: false
			,errors: {
				password: 'Password must be at least 6 characters'
			}});
		return false;
	} else {
		return true;
	}
}