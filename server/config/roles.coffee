ConnectRoles = require('connect-roles');


module.exports = (app) ->

	global.roles = new ConnectRoles(
		failureHandler: (req, res, action) ->
			# optional function to customise code that runs when
			# user fails authorisation
			if req.user? and !req.user.get('active')
				res.send(403, {error: 'Account Disabled', token: 'Account Disabled'})
			else
				res.send(403, {error: 'Access Denied - You don\'t have permission for: ' + action, token: 'Insufficient Roles'})

			#async: true
	)

	app.use(roles.middleware())

	roles.use 'POS', (req)->
		if req.body.pos_secret == (process.env.POS_SECRET || '123abc')
			return true
		else
			return null

	roles.use 'logged in', (req) -> 
		if req.user? and req.user.get('active')
			return true
		else
			#from the connect-roles api it seems that returning false here prevents the below roles from activating, not sure
			return false

	#some of the endpoints can be used by both the POS or a normal
	roles.use 'user or POS', (req) ->
		user = req.user
		if user.is('logged in') || user.is('POS')
			return true
		else
			return false

		
	roles.use 'admin', (req) -> 
		if req.user? and req.user.get('admin') == true 
			return true

		