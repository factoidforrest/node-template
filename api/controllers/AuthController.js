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
var moment = require('moment');

module.exports = {
	twitter: function (req, res) {
		var options = { 
			failureRedirect: '/'
		}

		passport.authenticate('twitter', options, 
			function (err, user) {
				redirectIfDeactivated(user, res, function(){
					console.log('authenticated via twitter with err', err, 'and user ', user)
					req.logIn(user, function (err) {
						if (err) {
							console.log(err);
							res.view('500');
							return;
						}


						var conf = sails.config;
						res.redirect(conf.apiRoot + '#/cards');
						return;
					});
				});
			})(req, res);


	},
	facebook: function (req, res) {
		var options = { 
			failureRedirect: '/',
			//scope = permissions
			scope: [
				'email'
			]
		}

		passport.authenticate('facebook', options, 
			function (err, user) {
				redirectIfDeactivated(user, res, function(){
					req.logIn(user, function (err) {
						if (err) {
							console.log(err);
							res.view('500');
							return;
						}


						var conf = sails.config;
						res.redirect(conf.apiRoot + '#/cards');
						return;
					});
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
				redirectIfDeactivated(user, res, function(){
					req.logIn(user, function (err) {
						if (err) {
							console.log(err);
							res.view('500');
							return;
						}


						var conf = sails.config;
						res.redirect(conf.apiRoot + '#/cards');
						return;
					});
				});
			})(req, res);
	}

	,local: function(req, res) {
		console.log("about to authenticate local user with request params: ", req.body)
		/*
		passport.authenticate('local', { successRedirect: '#/cards', failureRedirect: '/authfailure' }, function(err, user) {
			console.log('passport local got callback with err: ', err, " and user: ", user);
		});
		*/
		//let's just take passport out of the loop since it has tons of silent errors and stuff I don't like.
		console.log('finding local user to authenticate: ', email)
		var email = req.body.email;
		var password = req.body.password;
		User.findOne({ email: email }, function(err, user) {
			console.log('localhandler found one user', user)
			console.log('and an err of:', err)
			if (err) return res.json({error: err}); 
			if (!user) {
				return res.json({ error: 'Incorrect email.' });
			}
			
			if (typeof(user.password) === 'undefined'){
				return res.json({ error: 'You have previously logged in with this email through a social network, but not using a password.  You can register this email with a password by clicking register below and the accounts will merge, or log in with a social network.' })
			}

			if (!user.validPassword(password)) {
				return res.json({ error: 'Incorrect password.' });
			}

			//if the user email hasn't been confirmed.  When updating a user there might be a token and the old email is still valid so we check for the new_email property
			if (user.token !== null || user.hasOwnProperty('new_email')){
				//should offer a link to resend confirmation I guess. 
				return res.json({ error: 'You must confirm your email.  Please check your inbox.' });
			}
			if (accountActive(user)){
				req.logIn(user, function (err) {
					if (err) return res.json({error: err});
					return res.json({
						success: true,
						user: user
					});
				});
			} else {
				return res.json({
					success: false,
					error: "Account disabled."
				});
			}
		});


	}

	,profile : function(req, res) {
		 // console.log('the request is ', req)
		//seems to get requested even when the user isn't logged in so send a blank user if so
		if (typeof(req.user) === 'undefined'){
			console.log('profile requested but no user found from session, sending blank response')
			res.json({});
		} else {
			User.findOne({id : req.user.id}).done(function(err, user) {
				
				if (err) {
					res.send(501);
				} else {
					console.log('the user is:', user)
					console.log('responding with user json:', JSON.stringify(user));
					res.json(user);
				}
			});
		}
	}

	,register: function(req, res) {
		console.log('registering user with params: ', req.body);
		params = req.body;
		//verify passwords match and are long enough 
		if (passwordValid(params, res)){
			User.findByEmail(req.body.email).done(function(err, usr){
				if (err) {
					res.send(500, { error: "DB Error" });
				} else if (usr.length > 0) {
					usr = usr[0];
					if (typeof(usr.password) === 'undefined') {
						console.log('setting new password on old user:', usr)
						//TODO: need to confirm the email before this login method becomes active
						usr.setPassword(params.password, function(passwordError){
							if (passwordError) {
								return res.send(400, {error: passwordError})
							}
							require('crypto').randomBytes(48, function(ex, buf) {
								usr.token = buf.toString('hex');
								usr.save(function(err, usr){
									console.log(err)
									if (err) return res.send(500, {error: "DB Error"});

									Mail.sendConfirmation(usr, function(){});

									console.log('set password on previously passwordless user:', usr)
									res.json({
										success: true,
										errors: {}
									});
								});
							});
							
						});

					} else {
						res.send(200, {
							success: false
							, errors: { email: "A user already exists with this email and they already have a password.  To change your password, login and do so through the settings menu" }
						});
					}
					
				} else {
					//params.strategy = 'local';
					//store the password so we can put it back in the req when bcrypt overwrites it in the user beforecreate
					//not sure why bcrypt overwrites the params in place
					var password = req.body.password;
					var user = User.create(params).done(function(error, user){
						if (error) {
							res.send(500, {error: "DB Error"});
						} else {
							console.log('the user was saved as', user);
							req.body.password = password;
							res.json({
								success: true,
								errors: {}
							});
							


						}
					
					});
				}
			});
		}
	}

	,confirm: function(req, res){
		var token = req.query.token;
		console.log('got confirm request with token: ', token);
		User.confirmEmail(token, function(err){
			if (err) return res.redirect(sails.config.assetRoot + '#/?message=confirmfail');
			console.log('confirmed user email by token')
			res.redirect(sails.config.assetRoot + '#/?message=confirmsuccess')
		});
	}


	,logout : function(req, res) {
		req.logout();
//        res.redirect('//app.mobilegiftcard.com/');
		res.json({success:true});
	},

	resendConfirmation: function(req, res) {
		var email = req.query.email;
		User.findOne({email:email}).done(function(err,user){
			if (user.token === null) return res.send(405, {message: "User already confirmed email"})
			if (err) return res.status(404).json({message:"Server Error looking up user"});
			console.log("found user for resending confirmation:", user)
			Mail.sendConfirmation(user, function(er){
				if (er) return res.status(500).json({message:"Server Error sending email"});
				res.status(200).json({message:"Confirmation Sent"})
			});
		});
	},

	sendResetEmail: function(req, res){
		console.log('send reset password called with params: ', req.body)
		var email = req.body.email;
		User.findOne({email: email}, function(err, user){
			console.log('found user with matching email:', user)
			if (err) return res.send(404, {error: 'No matching email found'});
			Token.create({user_id: user.id}, function(err, token){
				console.log('created token: ', token)
				if (err) {
					console.log(err)
					return res.send(500, {error: 'Error creating token'});
				}
				Mail.sendPasswordReset(user, token, function(err){

					if (err){
						console.log(err)
						return res.send(500, {error: 'Error sending email'});
					}
					res.send(200, {message:'Email Sent'})
				})
			})
		})
	},

	resetPassword: function(req, res) {
		console.log('reset password called with params: ', req.body)
		var key = req.body.token;
		var password = req.body.password;
		Token.findOne({key:key}, function(err, token){
			if (err) return res.send(500, {error: 'Internal Server Error'});
			
			//if the token is over an hour old, consider it invalid.  moment() is now
			if (moment().subtract(1, 'hour').isAfter(token.createdAt)){
				return res.send(400, {error: 'Token Expired'});
			} else {
				User.findOne({id: token.user_id}, function(err, user){
					if (err) return res.send(500, {error: 'Internal Server Error'});
					user.setPassword(password, function(passwordError){
						if (passwordError) {
							return res.send(400, {error: passwordError})
						}
						user.save(function(err, user){
							//maybe log the user in here.  Maybe make them enter their password again(as below) since that way they might remember
							if (err) return res.send(500, {error: 'Internal Server Error'});
							return res.send(200, {message: 'Password Reset'});

						})
					})
				});
			}
		});
	},

	update : function(req, res) {
		params = req.body;
		User.findOne({
			id : req.user.id
		}).done(function(err, user) {
			if (err){
				return res.send(500, {error: 'Internal Server Error '+  err.message})
			}
			console.log('updating user', user);
			console.log('with new attributes: ', params)
			if(!user) {
				return res.send(404, {error : 'No User Found'});
			}

			//update the email
			if (params.email !== user.email) {
				//store the email in a new property on the user new_email which gets swapped for email once the email is confirmed
				user.new_email = params.email;
				require('crypto').randomBytes(48, function(ex, buf) {
	      	user.token = buf.toString('hex');
	      	var to = user.new_email;
	      	Mail.sendConfirmation(attrs, next, to);
	    	});
			} 

			//update the password
			if (params.hasOwnProperty('password') || params.password !== ''){
				if (!user.validPassword(params.currentPassword)) {
					return res.send(400, {error: 'Current password was incorrect.  '})
				}
				//password valid handles sending errors to the response object.  If it fails, just exit
				if (passwordValid(params, res)){


					user.setPassword(params.password, function(passwordError){
						if (passwordError) {
							return res.send(400, {error: passwordError})
						}
					});
				} else {
					return;
				}
			}
			user.firstname = params.firstname;
			user.lastname = params.lastname;

			user.save(function(err, saved){
				if (err) {
					return res.send(500, {error : err.message});
				}

				return res.json(saved);

			});
		});
	},






/**
	 * Overrides for the settings in `config/controllers.js`
	 * (specific to AuthController)
	 */
	_config: {}

	
};


//checks if the password is acceptable during registration
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
	} else if (typeof(params.password) === 'undefined' || params.password.length < 6) {
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

function accountActive(user){
	if (user.deactivated === true){
		return false;
	} else {
		return true;
	}
}

function redirectIfDeactivated(user, res, success){
	if (!accountActive(user)){
		return res.redirect(sails.config.assetRoot + '#/?message=deactivated')
	} else {
		success();
	}
}