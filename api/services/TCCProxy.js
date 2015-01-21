/**
 * TCCTestCardController
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

var request = require("request"),
    q = require("q");

var inquiryBodyForCard = function(card) {
    return {
        'hdr':
        {
            'live':'',
            'fmt':'MGC',
            'ver':'1.0.0',
            'uid':'14d4fd5a-488e-4544-ba4a-c73cd978c5bb',
            'cliUid':'59344556-3C62-42B0-81A1-284EACCFF949',
            'cliId':93,
            'locId':1,
            'rcId':0,
            'term':'1',
            'srvId':518,
            'srvNm':'',
            'txDtTm':'04/14/2014',
            'key':'',
            'chk':'12345'
        },
        'txs':
            [
                {
                    'typ':2,
                    'crd':card,
                    'amt':''
                }
            ]
    }
};

var activateBodyForCard = function(card, amount) {
    return {
        'hdr':
        {
            'live':'',
            'fmt':'MGC',
            'ver':'1.0.0',
            'uid':'14d4fd5a-488e-4544-ba4a-c73cd978c5bb',
            'cliUid':'59344556-3C62-42B0-81A1-284EACCFF949',
            'cliId':93,
            'locId':1,
            'rcId':0,
            'term':'1',
            'srvId':518,
            'srvNm':'',
            'txDtTm':'04/14/2014',
            'key':'',
            'chk':'12345'
        },
        'txs':
            [
                {
                    'typ':4,
                    'crd':card,
                    'amt':amount
                }
            ]
    }
};

var redeemBodyForCard = function(card, amount) {
    return {
        'hdr':
        {
            'live':'',
            'fmt':'MGC',
            'ver':'1.0.0',
            'uid':'14d4fd5a-488e-4544-ba4a-c73cd978c5bb',
            'cliUid':'59344556-3C62-42B0-81A1-284EACCFF949',
            'cliId':93,
            'locId':1,
            'rcId':0,
            'term':'1',
            'srvId':518,
            'srvNm':'',
            'txDtTm':'04/14/2014',
            'key':'',
            'chk':'12345'
        },
        'txs':
        [
            {
                'typ':5,
                'crd':card,
                'amt':amount
            }
        ]
    }

}


module.exports = {

    //TODO make these one method which takes a callback, get that url out of the code and into a sails config var

    getTCCInquiry : function(card_number) {
        
        var deferred = q.defer();

        var url = 'http://64.73.249.146/Partner/ProcessJson';
        var options = {
            method: 'post',
            body: inquiryBodyForCard(card_number),
            json: true,
            url: url
        };
        console.log('request to tcc is  ', options.body)
        request(options, function (err, httpResponse, body) {
            console.log('res body is', body)
            if (err || body.txs.length === 0) {
                return deferred.reject([err,body]);
            }

            var txn = body.txs[0];
            deferred.resolve({
                card_number : txn.crd,
                status : txn.crdStat,
                balance : txn.bal,
                previousBalance : txn.prevBal
            });
        })
        return deferred.promise;
    },

    activateTCCCard : function(card_number, amount) {
        var deferred = q.defer();

        var body = activateBodyForCard(card_number, amount);
        //shouldnt be hardcoded
        var url = 'http://64.73.249.146/Partner/ProcessJson';
        var options = {
            method: 'post',
            body: activateBodyForCard(card_number, amount),
            json: true,
            url: url
        };
        request(options, function (err, httpResponse, body) {

            if (err || body.txs.length === 0) {
                deferred.reject(err);
            }

            var txn = body.txs[0];
            deferred.resolve({
                card_number : txn.crd,
                status : txn.crdStat,
                balance : txn.bal,
                previousBalance : txn.prevBal
            });
        })
        return deferred.promise;

    },

    redeemTCCCard : function(card_number, amount) {
        var deferred = q.defer();

        var url = 'http://64.73.249.146/Partner/ProcessJson';
        var options = {
            method: 'post',
            body: redeemBodyForCard(card_number, amount),
            json: true,
            url: url
        };
        request(options, function (err, httpResponse, body) {

            if (err || body.txs.length === 0) {
                deferred.reject(err);
            }

            var txn = body.txs[0];
            deferred.resolve({
                card_number : txn.crd,
                status : txn.crdStat,
                balance : txn.bal,
                previousBalance : txn.prevBal
            });
        })
        return deferred.promise;

    }




};
