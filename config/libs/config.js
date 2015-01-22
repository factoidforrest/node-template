module.exports.configure = function(done) {

	var defaults = {
		requestLimit: 500,
		transactionLimit: 100
	};

	Configuration.findOne({id : {$exists : 0}},function(err, conf){
		console.log('found existing conf', conf)
		if (conf === undefined){
			console.log('creating new configuration from defaults')
			Configuration.create(defaults, function(err, newConf){
				load(newConf, done)
			})
		} else {
			console.log('loading stored configuration')
			load(conf, done)
		}
	})
}

function load(conf, done){
	console.log('config vars:', conf.variables());
	sails.config.configVars = conf.variables();
	done();
}