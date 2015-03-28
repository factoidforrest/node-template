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
		giftId = req.body.gift_id
		query = {where: {from_id: req.user.get('id')}, orWhere: {to_email: req.user.get('email')}, andWhere: {id : giftId}}
		console.log('revoke query is ', query)
		Gift.query(query).fetch({withRelated: ['card']}).then (gift) ->
			logger.info('found gift to revoke', gift.attributes)
			if !gift?
				res.send(404, {name:'giftNotFound', message: "Couldn't find this gift"})
			gift.revoke (err, gift) ->
				if err?
					console.log('gift controller caught error while revoking card: ', ere)
					return res.send(err.code, err)
				res.json(gift)
	
	app.post '/gift/accept', roles.is('logged in'), (req, res) ->

		logger.info('accepting gift using parameters ', req.body)
		logger.info('by user', req.user.toJSON())
		giftId = req.body.gift_id

		#edge case: user changes email after gift is sent
		Gift.forge(id:giftId, to_email: req.user.get('email'), status: 'pending').fetch(withRelated:['card']).then (gift) ->
			if !gift?
				return res.send(404, {name: 'giftNotFound', message: "No pending gift was found"})
			gift.accept (err, card) ->
				if err?
					return res.send(err.code, err)
				res.send(card)



			