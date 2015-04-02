tcc = require '../../services/tcc'
async = require 'async'

module.exports = (bookshelf) ->
	global.Program = bookshelf.Model.extend({
		tableName: 'programs'
		hasTimestamps: true
		#visible: ['key', 'created_at']


		},{
			#class methods

			refresh: (done) ->
				self = this
				tcc.getPrograms (err, programs) ->
					return done(err) if err?
					async.each programs, findOrCreate, (err) ->
						done()


		})
	return Program

findOrCreate = (program, cb) ->
	forged = Program.forge(client_id: program.mauid)
	forged.fetch().then (fetchedProgram) ->
		if !fetchedProgram?
			forged.set('description', program.desc)
			forged.save().then (savedProgram) ->
				logger.info('created new program ', savedProgram.attributes)
				cb()
		else
			logger.info('program already existed: ', fetchedProgram.attributes)
			cb()

			