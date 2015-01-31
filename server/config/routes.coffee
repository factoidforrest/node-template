module.exports = (app) ->
	#auth
	require('../controllers/authenticationController')(app)