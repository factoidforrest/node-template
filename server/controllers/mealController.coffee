
module.exports = (app) ->

	###
		transaction:
		t.integer('user_id').index()
		t.integer('card_id').index()
		t.string('card_number').index()
		t.float('amount')
		t.string('type')
		t.json('data')
		t.string('status')

		Meal:
		t.integer('restaurant_id').index()
	  t.float('balance')
	  t.json('items')
	  t.string('key').index()
	  t.string('status').defaultTo('unpaid')
	###
	app.post '/meal/create', roles.is('POS'), (req, res) ->
		req.body.meal.price ?= req.body.meal.balance
		clientIds = req.body.meal.programs 
		delete req.body.meal.programs
		#token logic happens in a before save hook on model
		Meal.forge(req.body.meal).save().then (meal) ->
			meal.attachPrograms clientIds, (err, meal) ->
				logger.info('created meal: ', meal.attributes)
				res.send(meal)
			
	app.post '/meal/update', roles.is('POS'), (req, res) ->
		delete req.body.meal.programs
		properties = req.body.meal
		properties.balance ?= properties.price
		Meal.forge(key: properties.key).fetch().then (meal) ->
			if !meal?
				return res.send(400, {name: 'notFound', message: 'No meal matching that key was found'})
			meal.set(properties).save().then(savedMeal) ->
				res.send savedMeal


	app.post '/meal/checkout', roles.is('POS'), (req, res) ->
		console.log('checkout with params:' , req.body)
		Meal.forge(key: req.body.key).fetch(withRelated: ['transactions.card']).then (meal) ->
			logger.info('got meal ', meal.attributes)
			console.log(meal)
			if !meal?
				return res.send(404, {name: 'mealNotFound', message: 'No meal matching that key was found'})
			meal.checkout (err, meal) ->
				if err?
					return res.send(err.code, err)
				res.send(meal)




