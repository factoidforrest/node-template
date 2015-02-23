module.exports = (app) ->
	app.post '/gift/send', roles.is('logged in'), (req, res) ->
		#Gift.send(req.body, req.user, )

	app.post '/gift/list', roles.is('logged in'), (req, res)->
		#fetch both inbound and outbound gifts
		queryParams = {where: {from_id: req.user.get('id')}, orWhere: {to_email: req.user.get('email')}}
		Gift.query(queryParams).fetchAll(withRelated: ['card', 'from']).then (gifts) ->
			incoming = gifts.where({to_email: req.user.get('email')})
			outgoing = gifts.where({from_id: req.user.get('id')})
			res.json {incoming: incoming, outgoing: outgoing}

			