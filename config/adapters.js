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
var defaultAdapter = process.env.NODE_ENV === 'production' ? 'mongoprod' : 'mongodev'
module.exports.adapters = {

  // If you leave the adapter config unspecified 
  // in a model definition, 'default' will be used.

  //this is the wrong way to do this but the right way(env.js) isn't working so there

  'default': defaultAdapter,

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
  mongostaging: {
      module   : 'sails-mongo',
      url: process.env.DATABASE_URI || process.env.MONGOLAB_URI
  },
  mongodaily: {
      module   : 'sails-mongo',
      url: process.env.DATABASE_URI || process.env.MONGOLAB_URI
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