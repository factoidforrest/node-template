Braintree = require '../services/braintree'

module.exports = (app) ->

	# I don't think we need to authenticate the user for this, do we?
	app.post '/payment/clienttoken', (req, res) ->
		Braintree.getClientToken (err, token) ->
			if err?
				return res.send(err.code, err)
			res.json {token: token}