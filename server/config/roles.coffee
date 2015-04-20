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

	roles.use 'POS', POS

	roles.use 'logged in', loggedIn

	#some of the endpoints can be used by both the POS or a normal
	roles.use 'user or POS', (req) ->
		loggedIn(req) or POS(req)

		
	roles.use 'admin', (req) -> 
		if req.user? and req.user.get('admin') == true 
			return true

		
loggedIn = (req) ->
	req.user? and req.user.get('active')

POS = (req) ->
	req.body.pos_secret == (process.env.POS_SECRET || '123abc')