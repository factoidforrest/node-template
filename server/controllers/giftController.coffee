module.exports = (app) ->
	app.post '/gift/give', roles.is('logged in'), (req, res) ->
		params = req.body
		