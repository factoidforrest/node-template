/**
* GiftcardGift.js
*
* @description :: TODO: You might write a short summary of how this model works and what it represents here.
* @docs        :: http://sailsjs.org/#!documentation/models
*/

module.exports = {

  attributes: {
      giftCardId: 'string',
      giftRecipientEmail: 'string',
      giftMessage: 'string',
      giftStatus: 'string'
  },
  //untested since the prereqs are complex.  Should manually test.
  toJSON: function() {
  	var json = this;
  	GiftCard.findOne({id: this.giftCardId}, function(err, card){
  		json.card = JSON.stringify(card);
  		return json;
  	})
  }
};