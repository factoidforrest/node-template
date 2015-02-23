
# This middleware checks if the request contains a token and if so adds the corresponding user to the req object

module.exports = (req, res, next) ->
	key = req.body.token
	if not key?
		return next()
	else
		Token.forge(key: key, type:'login').fetch(withRelated: ['tokenable']).then (token) ->
			logger.info 'fetched token from database', token
			if not token?
				logger.info('token invalid')
				return res.send(401, {error: 'Token Invalid', token: 'Invalid'})
			else if token.expired(app.get('token_expiry')) 
				logger.info('token expired')
				return res.send(401, {error: 'Token Expired', token: 'Expired'})
			else
				logger.info('token accepted')
				user = token.related('tokenable')

				if user.get('active')
					logger.info('logged in user:', JSON.stringify(user))
					req.user = user
					return next()
				else
					return res.send(403, error: "Account disabled.")



	