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
			program: req.body.program
			user_id: req.user.get('id')
			nonce: req.body.nonce
			#payment stuff
		}
		Card.generate properties, (err, card) ->
			if err?
				logger.info('Card Creation Error ', err)
				console.log(err)
				return res.send(err.code || 400, {name: err.name, message: err.message})
			res.send card


	app.post '/card/refill', roles.is('logged in'), (req, res) ->
		properties = {
			balance: req.body.balance
			id: req.body.id
			#payment stuff
		}
		Card.refill properties, (err, card) ->
			if err?
				return res.send(err.code, err)
			res.send card


	app.post '/card/info', roles.is('logged in'), (req, res) ->
		cardId = req.body.id
		Card.forge(user_id: req.user.id, id: cardId).fetch().then((card) ->
			if card?
				res.json(card)
			else
				res.send(404, error: "Card not found")
		)

	app.post '/card/list', roles.is('logged in'),  (req, res) ->
		#maybe take more params and join them to the query to optionally filter
		Card.forge(user_id: req.user.id).fetchAll().then((cards) ->
			console.log('retreived cards ', JSON.stringify(cards))
			Card.syncGroup cards, (err, syncedCards) ->
				console.log('synced with tcc and saved cards ', JSON.stringify(syncedCards))
				res.json syncedCards
				###
				res.json cards.models.map (card)  ->
					return card.json()
				###
		)
