/**
 * GmailAccountController
 *
 * @module      :: Controller
 * @description	:: A set of functions called `actions`.
 *
 *                 Actions contain code telling Sails how to respond to a certain type of request.
 *                 (i.e. do stuff, then send some JSON, show an HTML page, or redirect to another URL)
 *
 *                 You can configure the blueprint URLs which trigger these actions (`config/controllers.js`)
 *                 and/or override them with custom routes (`config/routes.js`)
 *
 *                 NOTE: The code you write here supports both HTTP and Socket.io automatically.
 *
 * @docs        :: http://sailsjs.org/#!documentation/controllers
 */

var googleapis = require('googleapis'),
    q = require('q'),
    passport = require('passport');

var getThreads = function(req, res) {

    googleapis
        .discover('urlshortener', 'v1')
        .discover('plus', 'v1')
        .execute(function(err, client) {
            if (err) {
                console.log('Problem during the client discovery.', err);
                return;
            }
            var params = { shortUrl: 'http://goo.gl/DdUKX' };
            var getUrlReq = client.urlshortener.url.get(params);

            getUrlReq.execute(function (err, response) {
                console.log('Long url is', response.longUrl);
                res.json({ url : response.longUrl});
            });

            var getUserReq = client.plus.people.get({ userId: '+burcudogan' });

            getUserReq.execute(function(err, user) {
                if (user) {
                    console.log('User id is: ' + user.id);
                }
            });
        });
};

var authenticate = function(req, res) {
    var CLIENT_ID = '636252831537-11abidpmup9t3u8rq4e33oob32nhm3td.apps.googleusercontent.com';
};


module.exports = {

    threads : getThreads,
    auth : authenticate,

  


  /**
   * Overrides for the settings in `config/controllers.js`
   * (specific to GmailAccountController)
   */
  _config: {}

  
};
