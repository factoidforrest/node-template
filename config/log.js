/**
 * Logger configuration
 *
 * Configure the log level for your app, as well as the transport
 * (Underneath the covers, Sails uses Winston for logging, which 
 * allows for some pretty neat custom transports/adapters for log messages)
 *
 * For more information on the Sails logger, check out:
 * http://sailsjs.org/#documentation
 */
var winston = require('winston');
require('winston-mongodb').MongoDB;

var customLogger = new winston.Logger({
       
});

mongoOptions = {
  db: 'mobile-gift-card'
}
customLogger.add(winston.transports.MongoDB, mongoOptions);

module.exports = {
  // Valid `level` configs:
  // i.e. the minimum log level to capture with sails.log.*()
  //
  // 'error'	: Display calls to `.error()`
  // 'warn'	: Display calls from `.error()` to `.warn()`
  // 'debug'	: Display calls from `.error()`, `.warn()` to `.debug()`
  // 'info'	: Display calls from `.error()`, `.warn()`, `.debug()` to `.info()`
  // 'verbose': Display calls from `.error()`, `.warn()`, `.debug()`, `.info()` to `.verbose()`
  //

  notify:function() {
    
    console.log('logging enabled')
    Sails.log('info', 'logging enabled')
  },
  log: {
    level: 'info',
    filePath: 'application.log'

    ,custom: customLogger
  }

};
