var fs = require('fs');
var exports;

switch(process.env.NODE_ENV){
    case 'production': exports = {
    		apiRoot : process.env.APIROOT || "https://localhost:1337/",
    		assetRoot : process.env.ASSETROOT || "https://localhost:1337/",
    		TCC: process.env.TCC ||  'http://64.73.249.146/Partner/ProcessJson',
    		clientID: process.env.CLIENTID || 73,
    		ssl: {
    			key: fs.readFileSync('ssl/mobilegiftcard.key')
        	, cert: fs.readFileSync('ssl/mgc_ssl_wildcard.crt')
    		}
    		, models: {
    			connection: 'mongoprod'
    		}
    	};
        break;
    case 'staging': exports = {
    		apiRoot : process.env.APIROOT || "https://localhost:1337/",
    		assetRoot : process.env.ASSETROOT || "https://localhost:1337/",
    		TCC: process.env.TCC ||  'http://64.73.249.146/Partner/ProcessJson',
    		clientID: process.env.CLIENTID || 73,
    		ssl: {
    			key: fs.readFileSync('ssl/mobilegiftcard.key')
        	, cert: fs.readFileSync('ssl/mgc_ssl_wildcard.crt')
    		}
    		, models: {
    			connection: 'mongostaging'
    		}
    	};
        break;
    case 'daily': exports = {
    		apiRoot : process.env.APIROOT || "https://localhost:1337/",
    		assetRoot : process.env.ASSETROOT || "https://localhost:1337/",
    		TCC: process.env.TCC ||  'http://64.73.249.146/Partner/ProcessJson',
    		clientID: process.env.CLIENTID || 73,
    		ssl: {
    			key: fs.readFileSync('ssl/mobilegiftcard.key')
        	, cert: fs.readFileSync('ssl/mgc_ssl_wildcard.crt')
    		}
    		, models: {
    			connection: 'mongodaily'
    		}
    	};
        break;
    default: exports = {
        apiRoot : "https://localhost:1337/",
        assetRoot : "https://localhost:1337/",
        TCC: 'http://64.73.249.146/Partner/ProcessJson',
        clientID: 73,
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


