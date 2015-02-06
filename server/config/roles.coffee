ConnectRoles = require('connect-roles');


module.exports = (app) ->

	global.roles = new ConnectRoles(
		failureHandler: (req, res, action) ->
			# optional function to customise code that runs when
			# user fails authorisation
			if req.user? and req.user.get('active')
				res.send(403, {error: 'Account Disabled', token: 'Account Disabled'})
			else
				res.send(403, {error: 'Access Denied - You don\'t have permission to: ' + action, token: 'Insufficient Roles'})

			#async: true
	)

	app.use(roles.middleware())


	roles.use 'logged in', (req) -> 
		if req.user? and req.user.get('active')
			return true
		else
			#from the connect-roles api it seems that returning false here prevents the below roles from activating, not sure
			return false

		
	roles.use 'admin', (req) -> 
		if req.user.get('admin') == true 
			return true

		