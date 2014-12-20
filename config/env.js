console.log('loaded development config file ')
var fs = require('fs');
var exports;

if (process.env.NODE_ENV === 'production') {
	exports = {
		ssl: {
			key: fs.readFileSync('ssl/prod.key')
    	, cert: fs.readFileSync('ssl/prod.cert')
		}
		, models: {
			connection: 'mongoprod'
		}
	}
} else {
	exports = {
		ssl: {
			key: fs.readFileSync('ssl/dev.key')
    	, cert: fs.readFileSync('ssl/dev.cert')
		}
		, models: {
			connection: 'mongodev'
		}
	}
}

module.exports = exports;


