module.exports = (app) ->
	#auth
	app.set('assetRoot', process.env.ASSETROOT || 'localhost:1337')
	
	require('../controllers/authenticationController')(app)
	require('../controllers/userController')(app)