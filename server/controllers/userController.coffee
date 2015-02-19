acceptablePassword = require('./authenticationController').acceptablePassword


module.exports = (app) ->

	app.get '/user/confirm', (req, res) ->
		token = req.query.token
		console.log('got confirm request with token: ', token)

		User.confirmEmail token, (err) ->
			return res.redirect(app.get('assetRoot') + '#/?message=confirmfail') if (err) 
			console.log('confirmed user email by token')
			res.redirect(app.get('assetRoot') + '#/?message=confirmsuccess')


	app.post '/user/info', roles.is('logged in'), (req, res) ->
		res.send(req.user.json())

	app.post '/user/sendpasswordreset', (req, res) ->
		email = req.body.email
		User.forge(email:email).fetch().then (user) ->
			if !user?
				res.send(404, {error: 'User not found', email: 'User not found'})
			else
				user.sendPasswordReset ->
					res.send(200, {status: 'Success'})

	app.post '/user/resetpassword', (req, res) ->
		key = req.body.key
		console.log('looking for reset token with key', key)
		password = req.body.password
		Token.forge(key: key).fetch(withRelated: ['tokenable']).then (token) ->
			if !token?
				return res.send(404, error: 'Token not found')
			if acceptablePassword(req.body, res)
				user = token.related('tokenable')
				user.setPassword req.body.password, () ->
					user.save().then (user) ->
						return res.send(200, {status: 'success'})


	app.post '/user/testtoken', roles.is('logged in'), (req, res) ->
		console.log('called token test')
		user = req.user
		res.send(user.json())

