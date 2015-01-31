require('./libs/lift')

describe('logs', function(){
	it('should log', function(){
		sails.log.info('YOU SHOULD SEE THIS IF LOGGING IS WORKING')
	})
})