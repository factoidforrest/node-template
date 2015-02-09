async = require 'async'

registered = false
process.env.NODE_ENV = 'test'

unless registered
	console.log('registering destroy hook')
	before (done)->
		destroyAll (done)
		registered = true

module.exports.destroyAll = destroyAll = (done) ->
	console.log('calling async destroy on models')
	async.map [User, Token], destroy, (err, results) ->
		console.log('destroyed all')
		done()



module.exports.destroy = destroy = (model, cb) ->
	model.collection().fetch().then (collection) ->
		collection.invokeThen('destroy').then -> 
			cb()
