passport = require 'passport'

module.exports = (app) ->

	app.post '/card/import', roles.is('logged in'),  (req, res) ->
		console.log('import card called with params:', req.body)
		properties = {
			number:req.body.card_number
			user_id: req.user.get('id')
		}
		Card.import properties, (err, card) ->
			console.log('got error importing:', err)
			if err?
				return res.send(400, {name:err.name, error: err.message})
			res.send card
	
	


	app.post '/card/create', roles.is('logged in'), (req, res) ->
		console.log('card create controller called with params ', req.body)
		properties = {
			balance: req.body.balance
			program_id: req.body.program_id
			user_id: req.user.get('id')
			nonce: req.body.nonce
			#payment stuff
		}
		Card.purchase properties, (err, card) ->
			if err?
				logger.info('Card Creation Error ', err)
				console.log(err)
				return res.send(err.code || 400, err)# {name: err.name, message: err.message})
			res.send card


	app.post '/card/refill', roles.is('logged in'), (req, res) ->
		properties = {
			amount: req.body.amount
			id: req.body.id
			location_id: 1 || req.body.location_id
			user_id: req.user.get('id')
			nonce: req.body.nonce
		}
		Card.refill properties, (err, card) ->
			if err?
				return res.send(err.code, err)
			res.send card

	app.post '/card/posfill', roles.is('POS'), (req, res) ->
		properties = {
			amount: req.body.amount
			number: req.body.number
			location_id: req.body.location_id
			client_id: req.body.client_id
		}
		Card.posFill properties, (err, card) ->
			if err?
				return res.send(err.code, err)
			res.send card


	app.post '/card/redeem', roles.is('user or POS'), (req, res) ->
		console.log('got redeem req')
		try
			console.log('card redeem with props', req.body)
			properties = req.body
			if req.user? then properties.user_id = req.user.get('id')

			Card.redeem properties, (err, data) ->
				if err?
					console.log 'card redeem error ', err
					return res.send(err.code, err)
				res.send data
		catch e
			console.log('caught exception ',e )
			console.log(e.trace)
		


	app.post '/card/info', roles.is('logged in'), (req, res) ->
		cardId = req.body.id
		Card.forge(user_id: req.user.id, id: cardId).fetch(withRelated: 'program').then((card) ->
			if card?
				res.json(card)
			else
				res.send(404, error: "Card not found")
		)

	app.post '/card/posinfo', roles.is('POS'), (req,res) ->
		number = req.body.number
		Card.forge(number:number).fetch(withRelated: 'program').then (card) ->
			return res.send(404, {name:'cardNotFound', message:'No card with that number was found in the system.'}) if !card?
			res.json(card)


	app.post '/card/list', roles.is('logged in'),  (req, res) ->
		#maybe take more params and join them to the query to optionally filter
		Card.forge(user_id: req.user.id).fetchAll(withRelated: 'program').then((cards) ->
			console.log('retreived cards ', JSON.stringify(cards))
			Card.syncGroup cards, (err, syncedCards) ->
				console.log('synced with tcc and saved cards ', JSON.stringify(syncedCards))
				res.json syncedCards
				###
				res.json cards.models.map (card)  ->
					return card.json()
				###
		)
