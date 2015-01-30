process.env.NODE_ENV = 'test'

should = require('chai').should()
assert = require('chai').assert
app = require('./../server')
db = app.get('db')

Location = db.models.location

describe 'location', ->
	describe 'creation', ->
		
		before (done) ->
			Location.forge({
				title:'bla'
				type:'bla'
				description:'bla'
				lat: 5
				lng: 5
			}).save().then -> 
				done()
		
		it 'should be a valid location', (done)->
			Location.where({title:'bla'}).fetch().then (loc) ->
				loc.should.have.property('attributes')
				loc.get('id').should.be.a('number')
				done()

		it 'should convert to json',  (done)->
			Location.where({title:'bla'}).fetch().then (loc) ->
				json = JSON.stringify(loc)
				done()
				#test attrs
				
				
		it 'should convert from collection to json', (done) ->
			Location.where({title:'bla'}).fetch().then (locs) ->
				console.log('collection json:')
				console.log JSON.stringify(locs)
				done()


		it 'should find by lat lng',  (done)->
			this.timeout = 5000
			box = {
				leftLat: '4.1',
				rightLat: '5.9',
				topLng: '4',
				bottomLng: '6' 
			}

			Location.findInBox(box).then (locations) ->
				locations.size().should.equal(1)
				done()


		it 'should destroy',  (done)->
			Location.where({title:'bla'}).fetchAll().then (locations) ->
				assert(locations.size() == 1, "exactly one location exists")
				locations.invokeThen('destroy').then -> 

					locations.fetch().then (updatedLocations) ->
						updatedLocations.size().should.equal(0)
						done()

