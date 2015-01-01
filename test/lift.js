

  before(function(done) {
    // Lift Sails and store the app reference
    require('sails').lift({

      // turn down the log level so we can view the test results
      log: {
        level: 'error'
      },
      port: 5000,
      //apiRoot : "https://localhost:5000/",
      //assetRoot : "https://localhost:5000/",
      adapters: {
        default: 'mongotest'
      }
      /*
       models: {
        connection: 'mongotest'
      }
    
      connections: {
        mongodb: {
          database: 'mobile-gift-card-test'
        }
      },
*/
    }, function(err, sails) {
         // export properties for upcoming tests with supertest.js
         sails.localAppURL = localAppURL = ( sails.usingSSL ? 'https' : 'http' ) + '://' + sails.config.host + ':' + sails.config.port + '';
         // save reference for teardown function
         console.log('lifted sails for testing')
         done(err);
       });

  });

  // After Function
  after(function(done) {
    sails.lower(done);
  });
