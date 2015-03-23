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

	app.post '/gift/revoke', roles.is('logged in'), (req, res) ->
		try
			giftId = req.body.gift_id
			query = {where: {from_id: req.user.get('id')}, orWhere: {to_email: req.user.get('email')}, andWhere: {id : giftId}}
			Gift.query(query).fetch({withRelated: ['card']}).then (gift) ->
				logger.info('found gift to revoke', gift.attributes)
				if !gift?
					res.send(404, {name:'giftNotFound', message: "Couldn't find this gift"})
				gift.revoke (err, gift) ->
					if err?
						console.log('gift controller caught error while revoking card: ', ere)
						return res.send(err.code, err)
					res.json(gift)
		catch e
			console.log('wtf ', e, e.stack)



			