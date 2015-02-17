passport = require 'passport'

module.exports = (app) ->

	app.post '/card/import', roles.is('logged in'),  (req, res) ->
		properties = {
			number:req.body.number
			user: req.user
		}
		Card.import properties, (err, card) ->
			if err?
				return res.send(err.code, {error: err.message})
			res.send card.json()


	app.post '/card/create', roles.is('logged in'), (req, res) ->
		properties = {
			balance: req.body.balance
			restaurant: req.body.restaurant
			#payment stuff
		}
		Card.create properties, (err, card) ->
			if err?
				return res.send(err.code, {error: err.message})
			res.send card.json()


	app.post '/card/refill', roles.is('logged in'), (req, res) ->
		properties = {
			balance: req.body.balance
			restaurant: req.body.restaurant
			#payment stuff
		}
		Card.refill properties, (err, card) ->
			if err?
				return res.send(err.code, {error: err.message})
			res.send card.json()


	app.post '/card/info', roles.is('logged in'), (req, res) ->
		cardId = req.body.id
		Card.forge(user_id: req.user.id, id: cardId).fetch().then((card) ->
			if card?
				res.json(card.json())
			else
				res.send(404, error: "Card not found")
		)

	app.post '/card/list', roles.is('logged in'),  (req, res) ->
		#maybe take more params and join them to the query to optionally filter
		Card.forge(user_id: req.user.id).fetchAll().then((cards) ->
			console.log('retreived cards ', cards.models[0].toJSON())
			res.json cards.models.map (card)  ->
				return card.json()
		)
