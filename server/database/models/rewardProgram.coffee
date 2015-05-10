module.exports = (bookshelf) ->
	global.RewardProgram = bookshelf.Model.extend({
		tableName: 'reward_programs'
		hasTimestamps: true
		#visible: ['key', 'created_at']


		},{

		})
	return RewardProgram
			