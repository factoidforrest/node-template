module.exports = (app) ->

	# I don't think we need to authenticate the user for this, do we?
	app.post '/program/list', (req, res) ->
		Program.fetchAll().then (programs) ->
			res.send(programs)

	app.post '/program/listbyclient', (req,res) ->
		Program.listByClient (programs) ->
			res.send(programs)