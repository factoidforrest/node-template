ConnectRoles = require('connect-roles');


module.exports = (app) ->

	global.roles = new ConnectRoles(
		failureHandler: (req, res, action) ->
			# optional function to customise code that runs when
			# user fails authorisation
			res.send(403, {error: 'Access Denied - You don\'t have permission to: ' + action})

			#async: true
	)

	app.use(roles.middleware())


	roles.use 'logged in', (req) -> 
		if req.user? and req.user.get('active')
			return true

		
	roles.use 'admin', (req) -> 
		if req.user.get('admin') == true 
			return true

		