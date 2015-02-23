

module.exports = (bookshelf) ->
	global.Configuration = bookshelf.Model.extend({
		tableName: 'configuration'
		hasTimestamps: true

		
		

		},{
			#class methods

		})
	return Configuration