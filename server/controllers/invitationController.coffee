module.exports = (app) ->
	app.post '/invitation/send', roles.is('logged in'), (req, res) ->
		