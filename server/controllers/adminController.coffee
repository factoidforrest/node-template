
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

	app.post '/admin/config', roles.is('admin'), (req, res) ->
		console.log('admin config called')
		#NOT WORKING RIGHT NOW, SILENT ERROR
		Configuration.fetchAll().then((configs) ->
			config = configs.first()
			logger.info('fetched config:', config.attributes)
			settings = req.body.settings
			if !settings?
				res.json config.get('settings')
			else
				logger.info('config updated by ', req.user.get('email'), ' to ', settings)
				config.set('settings', settings)
				config.save().then (savedConfig) ->
					res.json savedConfig.get('settings')
		).catch (err) ->
			console.log('caught db err : ', err)
			res.send(500, {name: 'DBerr', error: err})


