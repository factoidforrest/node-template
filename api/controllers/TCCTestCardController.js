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


module.exports = {

    find : function(req, res) {
        TCCTestCard.find().sort('card_number').done(function(err, cards) {
            if (err) {
                return res.send(500);
            }
            return res.json(cards);
        });
    },

    findOne : function(req, res) {
        TCCTestCard.findOne({
            id: req.params.id
        }).done(function(err, card) {
            TCCProxy.getTCCInquiry(card.card_number).then(function(tcc_card) {
                // Error handling
                if (err) {
                    return res.send(500);

                    // The User was found successfully!
                } else {
                    card.status = tcc_card.status;
                    card.balance = tcc_card.balance;
                    card.previousBalance = tcc_card.previousBalance;
                    card.save(function(err) {
                        tcc_card.id = req.params.id;
                        return res.json(tcc_card);
                    });


                }

            });


        });

    },

    activate : function(req, res) {
        var amount = req.params.amount;
        TCCTestCard.findOne({
            id: req.params.id
        }).done(function(err, card) {
            TCCProxy.activateTCCCard(card.card_number, amount).then(function(tcc_card) {
                // Error handling
                if (err) {
                    return console.log(err);

                    // The User was found successfully!
                } else {
                    return res.json(tcc_card);
                }
            });


        });

    },

    redeem : function(req, res) {
        var amount = req.params.amount;
        TCCTestCard.findOne({
            id: req.params.id
        }).done(function(err, card) {
            TCCProxy.redeemTCCCard(card.card_number, amount).then(function(tcc_card) {
                // Error handling
                if (err) {
                    return console.log(err);

                    // The User was found successfully!
                } else {
                    return res.json(tcc_card);
                }
            });


        });

    },


    /**
   * Overrides for the settings in `config/controllers.js`
   * (specific to TCCTestCardController)
   */
  _config: {}


};
