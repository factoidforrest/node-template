

module.exports = (bookshelf) ->
	global.Configuration = bookshelf.Model.extend({
		tableName: 'configurations'
		hasTimestamps: true

		
		

		},{
			#class methods

		})
	return Configuration