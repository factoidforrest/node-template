
module.exports = (app) ->

	app.post '/meal/create', roles.is('POS'), (req, res) ->

		Meal.forge(req.body.meal).save().then (meal) ->
			console.log('created meal: ', meal)
			response = {key:meal.get('key')}
			res.send(response)
		