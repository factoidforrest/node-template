ConnectRoles = require('connect-roles');


module.exports = (app) ->

	user = new ConnectRoles(
		failureHandler: (req, res, action) ->
	  # optional function to customise code that runs when
	  # user fails authorisation
	  	res.send(403, 'Access Denied - You don\'t have permission to: ' + action)

	  #async: true
	)

	app.use(user.middleware())


	user.use 'logged in', (req) -> 
	  if req.user?
	    return true

	  
	user.use 'admin', (req) -> 
	  if req.user.get('admin') == true 
	    return true

	  