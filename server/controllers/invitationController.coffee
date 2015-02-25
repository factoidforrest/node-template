module.exports = (app) ->

	app.post '/invitation/send', roles.is('logged in'), (req, res) ->
		
		Invitation.invite req.body.email, req.user, (err, invitation) ->
			if err?
				res.send(400, err)
			else
				res.json invitation
