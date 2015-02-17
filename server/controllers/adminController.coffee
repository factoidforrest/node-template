
module.exports= (app) ->

	app.post '/admin/deactivateuser', roles.is('admin'), (req, res) ->
		if req.body.user_id?
			query = {user_id: req.body.user_id}
		else if req.body.email?
			query = {email: req.body.email}
		else
			return res.send(400, {error: 'No email or user_id attribute'})

		User.forge(query).fetch().then (user) ->
			if !user?
				return res.send(404, {error: 'User not found'})
			if user.get('active') == false
				return res.send(400, {error: 'User already deactivated'})

			user.set 'active', false
			user.save().then (deactivated) ->
				res.send(200, {status: 'deactivated'})