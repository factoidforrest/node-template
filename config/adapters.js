/**
 * Global adapter config
 * 
 * The `adapters` configuration object lets you create different global "saved settings"
 * that you can mix and match in your models.  The `default` option indicates which 
 * "saved setting" should be used if a model doesn't have an adapter specified.
 *
 * Keep in mind that options you define directly in your model definitions
 * will override these settings.
 *
 * For more information on adapter configuration, check out:
 * http://sailsjs.org/#documentation
 */
//var defaultAdapter = process.env.NODE_ENV === 'production' ? 'mongoprod' : 'mongodev'
module.exports.adapters = {

  // If you leave the adapter config unspecified 
  // in a model definition, 'default' will be used.

  //this is the wrong way to do this but the right way(env.js) isn't working so there

  'default': 'mongodaily',

  // Persistent adapter for DEVELOPMENT ONLY
  // (data is preserved when the server shuts down)

  mongodev: {
      module   : 'sails-mongo',
      host     : 'localhost',
      port     : 27017,
      user     : '',
      password : '',
      database : 'mobile-gift-card'
  }, 

  //these duplicates probably shouldnt be here, we should read a single 
  mongostaging: {
      module   : 'sails-mongo',
      url: process.env.DATABASE_URI || process.env.MONGOLAB_URI
  },

  //export DATABASE_URI=mongodb://mobilegiftcard:mgcdaily@localhost:27017/admin
  //mongodb://[username:password@]host1[:port1][,host2[:port2],...[,hostN[:portN]]][/[database][?options]]
  mongodaily: {
      module   : 'sails-mongo',
      /*
      host: 'localhost',
      port: 27017,
      user: 'mobilegiftcard',
      password: 'mgcdaily',
      database: 'admin'
      */
      url: 'mongodb://heroku_app33233436:ktp26bb70gq7pfniv7i70veh4d@ds031641.mongolab.com:31641/heroku_app33233436'
  },
  mongoprod: {
      module   : 'sails-mongo',
      url: process.env.DATABASE_URI || process.env.MONGOLAB_URI
  },

  mongotest: {
      module   : 'sails-mongo',
      host     : 'localhost',
      port     : 27017,
      user     : '',
      password : '',
      database : 'mobile-gift-card-test'
  }

};