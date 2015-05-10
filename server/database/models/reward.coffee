module.exports = (bookshelf) ->
	global.Reward = bookshelf.Model.extend({
		tableName: 'rewards'
		hasTimestamps: true
		#visible: ['key', 'created_at']
		

		},{

		})
	return Reward
			