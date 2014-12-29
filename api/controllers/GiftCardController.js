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
    buy : function(req, res) {
        var amount = req.body.amount;
        var ownerId = req.user.id;

        TCCTestCard.findOne({status : {$exists : 0}}).done(function(err, card) {
            TCCProxy.activateTCCCard(card.card_number, amount).then(function(activeCard) {
                TCCProxy.getTCCInquiry(activeCard.card_number).then(function(tcc_card) {
                    tcc_card.ownerId = ownerId;
                    GiftCard.create(tcc_card).done(function(err,client) {
                        card.status = "consumed";
                        card.save(function (err, savedTccCard) {
                            if (err) {
                                return res.send(500, {error : err.message});
                            } else {
                                return res.json(client);
                            }
                        });
                    });
                });

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
            } else {
                return res.json(cards);
            }
        });
    },
    GiftCardsToAccept : function(req, res) {
        GiftCardGift.find({
            giftRecipientEmail: req.user.email
        }).done(function(err, cards) {

            // Error handling
            if (err) {
                return console.log(err);
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

            if(card.giftStatus === 'gifted') {
                return res.send(409, {error : 'Card Already Gifted'});
            }
            GiftCardGift.create({giftRecipientEmail : req.body.email, giftMessage : req.body.message, giftStatus : 'gifted', giftCardId : card.id, cardRemainingValue : card.balance}).done(function(){
                card.giftStatus = "gifted";
                card.save(function(err, saved){
                    // Error handling
                    if (err) {
                        console.log(err);
                        return res.send(500, {error : 'Internal Server Error saving Gift'});
                        
                    } else {
                        return res.json(saved);
                    }
                });
            })
        });
    },
    ungift : function(req, res) {
        GiftCard.findOne({
            ownerId: req.user.id,
            id : req.param("id")
        }).done(function(err, card) {

            if(card.giftStatus === 'retracted') {
                return res.send(409, {error : 'Card Already retracted'});
            }
            GiftCardGift.findOne({giftCardId : card.id, giftStatus : 'gifted'}).done(function(err, gift){
                //delete card.giftStatus;
                card.giftStatus = undefined;

                card.save(function(err, saved){
                    // Error handling
                    if (err) {
                        return res.send(409, {error : err.message});
                    }
                    gift.giftStatus = "retracted";
                    gift.save(function() {
                        return res.json(saved);
                    });
                });

            })
        });
    },
    acceptgift : function(req, res) {
        GiftCardGift.findOne({
            id : req.param("id")
        }).done(function(err, gift) {
            if (gift.giftStatus === 'giftaccepted') {
                return res.send(409, {error: 'Card Already been Accepted'});
            }
            gift.giftStatus = "giftaccepted";
            gift.save(function(err, gift) {
                GiftCard.findOne({
                    id: gift.giftCardId
                }).done(function(err, card){
                    card.giftStatus = "giftaccepted";
                    card.save(function(err, card) {
                        delete card.giftStatus;
                        delete card.id;

                        card.ownerId = req.user.id;
                        GiftCard.create(card).done(function(err, card) {
                            return res.json(card);
                        })
                    });
                });
            });
        })
   },
   rejectgift : function(req, res) {
        GiftCard.findOne({
            id : req.param("id")
        }).done(function(err, card) {

        if(card.giftStatus === 'rejected') {
            return res.send(409, {error : 'Card Already rejected'});
        }
        GiftCardGift.findOne({giftCardId : card.id, giftStatus : 'gifted'}).done(function(err, gift){
            //delete card.giftStatus;
            card.giftStatus = undefined;

            card.save(function(err, saved){
                // Error handling
                if (err) {
                    return res.send(409, {error : err.message});
                }
                gift.giftStatus = "rejected";
                gift.save(function() {
                    return res.json(saved);
                });
            });

        })
    });
},



  /**
   * Overrides for the settings in `config/controllers.js`
   * (specific to GiftCardController)
   */
  _config: {}

  
};
