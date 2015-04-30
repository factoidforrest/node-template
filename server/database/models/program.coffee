tcc = require '../../services/tcc'
async = require 'async'
_ = require 'underscore'

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

			listByClient: (done) ->
				try
					this.fetchAll().then (programs) ->
						console.log('fetched programs ', programs.models)
						groupedPrograms = []
						programs.each (program) ->
							clientName = program.get('client')
							#if we haven't already grouped those clients
							if _.where(groupedPrograms, {client: clientName}).length == 0
								client = {client: clientName}
								client.programs = programs.where {client: clientName}
								groupedPrograms.push client
						return done(groupedPrograms)
				catch e
					console.log('error':e)
					console.log(e.stack)
				




		})
	return Program

findOrCreate = (program, cb) ->
	forged = Program.forge(client_id: program.mauid)
	forged.fetch().then (fetchedProgram) ->
		if !fetchedProgram?
			forged.set('description', program.desc)
			forged.set('client', program.cli)
			forged.save().then (savedProgram) ->
				logger.verbose('created new program ', savedProgram.attributes)
				cb()
		else
			logger.verbose('program already existed: ', fetchedProgram.attributes)
			cb()

