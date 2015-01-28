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

var inquiryBody = function(card) {
    return {
        'hdr':
        {
            'live':'',
            'fmt':'MGC',
            'ver':'1.0.0',
            'uid':'14d4fd5a-488e-4544-ba4a-c73cd978c5bb',
            'cliUid':'59344556-3C62-42B0-81A1-284EACCFF949',
            'cliId':sails.config.clientID,
            'locId':1,
            'rcId':0,
            'term':'1',
            'srvId':518,
            'srvNm':'',
            //'txDtTm':'04/14/2014',
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

var activateBody = function(card, amount) {
    return {
        'hdr':
        {
            'live':'',
            'fmt':'MGC',
            'ver':'1.0.0',
            'uid':'14d4fd5a-488e-4544-ba4a-c73cd978c5bb',
            'cliUid':'59344556-3C62-42B0-81A1-284EACCFF949',
            'cliId':sails.config.clientID,
            'locId':1,
            'rcId':0,
            'term':'1',
            'srvId':518,
            'srvNm':'',
            //'txDtTm':'04/14/2014',
            'key':'',
            'chk':'12345'
        },
        'txs':
            [
                {
                    //type is svSale
                    'typ':4,
                    'crd':card,
                    'amt':amount
                }
            ]
    }
};

var redeemBody = function(card, amount) {
    return {
        'hdr':
        {
            'live':'',
            'fmt':'MGC',
            'ver':'1.0.0',
            'uid':'14d4fd5a-488e-4544-ba4a-c73cd978c5bb',
            'cliUid':'59344556-3C62-42B0-81A1-284EACCFF949',
            'cliId':sails.config.clientID,
            'locId':1,
            'rcId':0,
            'term':'1',
            'srvId':518,
            'srvNm':'',
            //'txDtTm':'04/14/2014',
            'key':'',
            'chk':'12345'
        },
        'txs':
        [
            {
                //type is svRed(eem)
                'typ':5,
                'crd':card,
                'amt':amount
            }
        ]
    }

}

var createBody = function(amount, program){
    return {
        'hdr':
            {
                'live':'',
                'fmt':'MGC',
                'ver':'1.0.0',
                'uid':'14d4fd5a-488e-4544-ba4a-c73cd978c5bb',
                'cliUid':'59344556-3C62-42B0-81A1-284EACCFF949',
                'cliId':sails.config.clientID,
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
                    //type is svRed(eem)
                    'typ':3,
                    'amt':amount,
                    'prog': program
                }
            ]
        
    }
}



module.exports = {

    //TODO make these one method which takes a callback, get that url out of the code and into a sails config var
    createCard : function(amount, program){
        var deferred = q.defer();

        var url = sails.config.TCC;
        var options = {
            method: 'post',
            body: createBody(amount, program),
            json: true,
            url: url
        };
        console.log('request to tcc for creating card is  ', options.body)
        request(options, function (err, httpResponse, body) {
            console.log('res for creating card is ', body)
            if (err || body.txs.length === 0) {
                console.log('rejecting promise with args ', [err,body])
                return deferred.reject([err,body]);
            }
            console.log('resolving promise')
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

    
    getTCCInquiry : function(card_number) {
        
        var deferred = q.defer();

        var url = sails.config.TCC;
        var options = {
            method: 'post',
            body: inquiryBody(card_number),
            json: true,
            url: url
        };
        console.log('request to tcc is  ', options.body)
        request(options, function (err, httpResponse, body) {
            console.log('res body is', body)
            if (err || body.txs.length === 0) {
                console.log('rejecting promise with args ', [err,body])
                return deferred.reject([err,body]);
            }
            console.log('resolving promise')
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

        var body = activateBody(card_number, amount);
        var url = sails.config.TCC;
        var options = {
            method: 'post',
            body: body,
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

        var url = sails.config.TCC;
        var options = {
            method: 'post',
            body: redeemBody(card_number, amount),
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
