#should probably switch to some appdir var instead of relative pathing
adapters = require('../../knexfile')

env = process.env.MGC_ENV || "development"

###
adapter = {
	"development": adapters.development
	"test": adapters.test
	"production": adapters.production
}
###

class Database
	constructor: () ->
		@knex = require('knex')(adapters[env])
		@bookshelf = require('bookshelf')(@knex)
		#console.log(@bookshelf)
		@models = {
			user: require('./models/user')(@bookshelf)
			token: require('./models/token')(@bookshelf)
			authentication: require('./models/authentication')(@bookshelf)
			card: require('./models/card')(@bookshelf)
		}
		console.log("Database connected")





#connect the db the first time it is required by server.coffee
db = new Database()

module.exports = db