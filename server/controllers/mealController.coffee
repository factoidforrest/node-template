
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
		req.body.meal.balance ?= req.body.meal.price
		Meal.forge(req.body.meal).save().then (meal) ->
			logger.info('created meal: ', meal)
			response = {key:meal.get('key')}
			res.send(response)
		
	app.post '/meal/update', roles.is('POS'), (req, res) ->
		properties = req.body.meal
		properties.balance ?= properties.price
		Meal.forge(key: properties.key).fetch().then (meal) ->
			if !meal?
				return res.send(400, {name: 'notFound', message: 'No meal matching that key was found'})
			meal.set(properties).save().then(savedMeal) ->
				res.send savedMeal


	app.post '/meal/checkout', (req, res) ->
		console.log('checkout with params:' , req.body)
		Meal.forge(key: req.body.key).fetch(withRelated: ['transactions']).then (meal) ->
			logger.info('got meal ', meal)
			console.log(meal)
			if !meal?
				return res.send(400, {name: 'notFound', message: 'No meal matching that key was found'})
			meal.checkout req.body, (err, meal) ->
				if err?
					return res.send(err.code, err)
				res.send(meal)




