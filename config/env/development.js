console.log('loaded development config file ')
module.exports = {
  //I guess you can set sails config stuff here like sails.config.whatever = whatever
  sails.config.api_url = sails.config.asset_url = 'https://localhost:1337/';

};

module.exports.models = {

  // Your app's default connection.
  // i.e. the name of one of your app's connections (see `config/connections.js`)
  //
  // (defaults to localDiskDb)
  connection: 'mongodev'
};