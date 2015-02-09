passport = require 'passport'

module.exports = (app) ->

	app.post '/card/import', roles.is('logged in'),  (req, res) ->
		
	app.post '/card/create', roles.is('logged in'), (req, res) ->
		
	app.post '/card/refill', roles.is('logged in'), (req, res) ->

	app.post '/card/info', roles.is('logged in'), (req, res) ->
		cardId = req.body.id
		Card.forge(user_id: req.user.id, id: cardId).fetchl().then((card) ->
			if card?
				res.json(card)
			else
				res.send(404, error: "Card not found")
		)

	app.post '/card/list', roles.is('logged in'),  (req, res) ->
		#maybe take more params and join them to the query to optionally filter
		Card.forge(user_id: req.user.id).fetchAll().then((cards) ->
			res.json(cards)
		)