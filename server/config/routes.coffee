module.exports = (app) ->
	#auth
	app.set('assetRoot', process.env.ASSETROOT || 'http://localhost:1337')
	app.set('apiRoot', process.env.APIROOT || 'http://localhost:3000')
	app.set('tccURL', process.env.TCC || 'http://64.73.249.146/Partner/ProcessJson')

	
	require('../controllers/authenticationController')(app)
	require('../controllers/userController')(app)
	require('../controllers/giftController')(app)
	require('../controllers/cardController')(app)