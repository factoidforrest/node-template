
# This middleware checks if the request contains a token and if so adds the corresponding user to the req object

module.exports = (req, res, next) ->
	key = req.body.token
	if not key?
		return next()
	else
		Token.forge(key: key).fetch(withRelated: ['tokenable']).then (token) ->
			logger.info 'Fetched token: ', token
			if not token?
				return res.send(401, {error: 'Token Invalid', token: 'Invalid'})
			else if token.expired(app.get('token_expiry')) 
				return res.send(401, {error: 'Token Expired', token: 'Expired'})
			else
				user = token.related('tokenable')
				req.user = user
				logger.info 'added this user to request:', req
				return next()



	