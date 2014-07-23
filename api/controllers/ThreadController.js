/**
 * ThreadController
 *
 * @module      :: Controller
 * @description    :: A set of functions called `actions`.
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
    _ = require('lodash');

var getClient = function (req) {
    var d = q.defer();
    console.log("failing here?");

    var auth = new googleapis.OAuth2Client('200927102479-37l48tk8uamrushob22ff8rg9dv9kl4n.apps.googleusercontent.com', 'lhpefdZAZQry95cokNDHj7DR', 'http://localhost:1337/auth/google/callback');
    auth.setCredentials({
        access_token: req.user.token
    });

    googleapis
        .discover('gmail', 'v1')
        .discover('plus', 'v1')
        .execute(function (err, client) {
            if (err) {
                d.reject(err);
            }

            d.resolve({client: client, auth: auth});
        });

    return d.promise;
}


var getThreads = function (req, res) {
    getClient(req).then(function (result) {
        result.client.gmail.users.threads.list({userId: "me"}).withAuthClient(result.auth).execute(function (err, response) {
            res.json({complete: response})
        });
    });
};

var getThread = function (req, res) {
    getClient(req).then(function (result) {
        result.client.gmail.users.threads.get({userId: "me", id: req.params.id}).withAuthClient(result.auth).execute(function (err, response) {
            console.log(response);
            res.json(response);
        });
    });
}

module.exports = {

    getMine: getThreads,
    get: getThread,

    /**
     * Overrides for the settings in `config/controllers.js`
     * (specific to ThreadController)
     */
    _config: {}


};
