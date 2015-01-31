
User = db.models.user

module.exports = (app) ->
	app.post 'auth/register', (req,res) ->
		winston.info "registering user with params: ", req.body
		params = req.body

		#verify passwords match and are long enough 
		if acceptablePassword(params, res)
			User.where({email : params.email}).fetch().then (usr) ->
				console.log('when registering user, found prexisting user')
				if not usr
					user = User.forge({email: params.email}).then (user) ->
						user.setPassword req.body.password, ()->
							user.save().then (saved)->
								console.log "the user was saved as", saved
								res.json({success: true, errors: {}})
				else
					if not usr.password
						console.log "setting new password on old user:", usr
						
						#TODO: need to confirm the email before this login method becomes active
						usr.setPassword params.password, () ->
							require("crypto").randomBytes 48, (ex, buf) ->
								usr.set 'token', buf.toString("hex")
								usr.save().then() ->
									console.log err
									if err
										return res.send(500,
											error: "DB Error"
										)

									#Mail.sendConfirmation usr, ->

									console.log "set password on previously passwordless user:", usr
									res.json
										success: true
										errors: {}

					else
						res.send 200,
							success: false
							errors:
								email: "A user already exists with this email and they already have a password.  To change your password, login and do so through the settings menu"
				return


	app.post 'auth/local',  (req,res) ->

		console.log "finding local user to authenticate: ", email
		email = req.body.email
		password = req.body.password
		User.findOne
			email: email
		, (err, user) ->
			console.log "localhandler found one user", user
			console.log "and an err of:", err
			return res.json(error: err)  if err
			return res.json(error: "Incorrect email.")  unless user
			return res.json(error: "You have previously logged in with this email through a social network, but not using a password.  You can register this email with a password by clicking register below and the accounts will merge, or log in with a social network.")  if typeof (user.password) is "undefined"
			return res.json(error: "Incorrect password.")  unless user.validPassword(password)
			
			#if the user email hasn't been confirmed.  When updating a user there might be a token and the old email is still valid so we check for the new_email property
			return res.json(error: "You must confirm your email.  Please check your inbox.")  if user.token isnt null or user.hasOwnProperty("new_email")
			if accountActive(user)
				req.logIn user, (err) ->
					return res.json(error: err)  if err
					res.json
						success: true
						user: user
			else
				res.json
					success: false
					error: "Account disabled."

			return



acceptablePassword = (params, res) ->
  if params.password isnt params.passwordConfirmation
    console.log "passwords didnt match"
    res.send 200,
      success: false
      errors:
        passwordConfirmation: "Passwords don't match"

    false
  
  #check password length
  else if typeof (params.password) is "undefined" or params.password.length < 6
    console.log "password too short"
    res.send 200,
      success: false
      errors:
        password: "Password must be at least 6 characters"

    false
  else
    true

