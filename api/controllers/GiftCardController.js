/**
 * GiftCardController
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
    create : function(req, res) {
        var cardNumber = req.body.card_number;
        var ownerId = req.user.id;
        
        TCCProxy.getTCCInquiry(cardNumber).then(function(tcc_card) {
            tcc_card.ownerId = ownerId;
            GiftCard.create(tcc_card).done(function(err,client) {
                if (err) {
                    return res.send(500, {error : err.message});
                } else {
                    return res.json(client);
                }
            });
        });
    },
    find : function(req, res) {
        GiftCard.find({
            ownerId: req.user.id
        }).done(function(err, cards) {

            // Error handling
            if (err) {
                return console.log(err);

                // The User was found successfully!
            } else {
                return res.json(cards);
            }
        });
    },
    gift : function(req, res) {
        GiftCard.findOne({
            ownerId: req.user.id,
            id : req.param("id")
        }).done(function(err, card) {
            // Error handling
            if (err) {
                return console.log(err);
            } else {
                return res.json(card);
            }
        });
    },



  /**
   * Overrides for the settings in `config/controllers.js`
   * (specific to GiftCardController)
   */
  _config: {}

  
};
