

module.exports = (app) ->

	app.get '/user/confirm', (req, res) ->
		token = req.query.token
		console.log('got confirm request with token: ', token)

		User.confirmEmail token, (err) ->
			return res.redirect(app.assetRoot + '#/?message=confirmfail') if (err) 
			console.log('confirmed user email by token')
			res.redirect(app.assetRoot + '#/?message=confirmsuccess')

	app.post '/user/testtoken', roles.is('logged in'), (req, res) ->
		console.log('called token test')
		user = req.user
		res.send(user)

