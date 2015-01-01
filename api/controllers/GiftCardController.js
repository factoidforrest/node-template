/**
 * GiftCardController
 *
 * @module      :: Controller
 * @description :: A set of functions called `actions`.
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
		console.log('got card number from client ', cardNumber)
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
		sails.info('buying a gift card:', req.body)
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

	//this API checks if the user being gifted exists, if not it returns a warning unless the request specifies 'invite: true'
	gift : function(req, res) {
		GiftCard.findOne({
			ownerId: req.user.id,
			id : req.param("id")
		}).done(function(err, card) {

			if(card.giftStatus === 'gifted') {
				return res.send(409, {error : 'Card Already Gifted'});
			}
			User.findOne({email:req.body.email}, function(err, user){
				if (err) {
					sails.error(err)
					return res.send(500, {error : 'Internal Server Error'});
				}
				if (typeof user === undefined && req.body.invite !== true) {
					var alreadyInvited;
					Invitation.findOne({email:req.body.email}, function(err, invitation){
						if (err) {
							console.log(err);
							return res.send(500, {error : 'Error looking up existing invites'})
						} 
						if (invitation){
							alreadyInvited = true;
							return res.json({status:'alreadyinvited', message:"This user has been invited but not yet joined.  Would you still like to gift them the card?  They can claim it when they make an account."})
						} else {
							alreadyInvited = false;
							return res.json({status:'noemail', message:"The user doesn't exist but we can still send the gift card to them and an invitation to join diner's group. They can claim the card when they make an account. "})
						}

					})
				} else {
					GiftCardGift.create({giftRecipientEmail : req.body.email, giftMessage : req.body.message, giftStatus : 'gifted', giftCardId : card.id, cardRemainingValue : card.balance}).done(function(){
						card.giftStatus = "gifted";

						card.save(function(err, saved){
							// Error handling
							if (err) {
								console.log(err);
								return res.send(500, {error : 'Internal Server Error saving Gift'});
								
							} else {
								saved.status = "good"
								if (req.body.invite === true  && !alreadyInvited){
									Invitation.invite(req.body.email, req.user, function(err, invitation){

									})
								}
								return res.json(saved);
							}
						});
					})
				}
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
