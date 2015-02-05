module.exports = (app) ->
	#auth
	app.set('assetRoot', process.env.ASSETROOT || 'http://localhost:1337')
	app.set('apiRoot', process.env.APIROOT || 'http://localhost:3000')

	require('../controllers/authenticationController')(app)
	require('../controllers/userController')(app)