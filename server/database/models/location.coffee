db = require('./../database')
knex = db.knex

module.exports = (bookshelf) ->
	Location = bookshelf.Model.extend({
		#instance methods

		tableName: 'locations'

		initialize: () ->
			#figure out how to set these on creating and updating events
			#this.set('created_at', knex.raw('now()'))
			#this.set('updated_at', knex.raw('now()'))
			#console.log('initializing location model with attributes')
			#console.log(this)
			return

		ratings: () ->
			#return this.hasMany(Ratings)
		
		toJSON: () ->
			self = this
			return {
				#"type": "Feature",
				"id": self.get('id')
				"title": self.get('title')
				"description": self.get('description')
				"coordinates": [self.get('lat'), self.get('lng')]
				
			}

	}, {
		#class methods
		findInBox: (box) ->
			db = require('./../database')
			knex = db.knex
			console.log('firing query: ')

			#note that sql between queries must go from small to big.  I'm guessing that will make problems around the map edges
			resultPromise = this
			.query('whereBetween','lat', [box.bottomLat, box.topLat])
			.query('whereBetween','lng', [box.leftLng, box.rightLng])
			.fetchAll()

			return resultPromise
	})
	return Location
