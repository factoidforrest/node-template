Payment = require '../services/payment'

module.exports = (app) ->

	# I don't think we need to authenticate the user for this, do we?
	app.post '/payment/clienttoken', (req, res) ->
		try 
			Payment.generateClientToken (err, token) ->
				if err?
					logger.info(' client token err', err)
					return res.send(err.code, err)
				res.json {token: token}
		catch e
			console.log('expection caught', e)