module.exports = (app) ->

	app.set('assetRoot', process.env.ASSETROOT || 'http://localhost:3001')
	app.set('apiRoot', process.env.APIROOT || 'http://localhost:3000')
	app.set('tccURL', process.env.TCC || 'http://64.73.249.146/Partner/ProcessJson')

	global.TCC = require '../services/tcc'
	
	require('../controllers/authenticationController')(app)
	require('../controllers/userController')(app)
	require('../controllers/giftController')(app)
	require('../controllers/cardController')(app)
	require('../controllers/mealController')(app)
	require('../controllers/adminController')(app)
	require('../controllers/invitationController')(app)
	require('../controllers/paymentController')(app)