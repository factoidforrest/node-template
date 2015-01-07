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

module.exports.adapters = {

  // If you leave the adapter config unspecified 
  // in a model definition, 'default' will be used.
  'default': 'mongodev',

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
  mongotest: {
      module   : 'sails-mongo',
      host     : 'localhost',
      port     : 27017,
      user     : '',
      password : '',
      database : 'mobile-gift-card-test'
  }, 

  mongoprod: {
    //not sure yet, leaving the same as dev for now but changing db name, actual db should have username and password and read env vars to get them
      module   : 'sails-mongo',
      url: process.env.DATABASE_URI
  }



};