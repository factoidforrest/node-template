/**
 * GiftCard
 *
 * @module      :: Model
 * @description :: A short summary of how this model works and what it represents.
 * @docs		:: http://sailsjs.org/#!documentation/models
 */

module.exports = {

  attributes: {
  	card_number: {
  		type:'string',
  		unique: true
  	},
    cardInitialValue: 'float',
    cardRemainingValue: 'float',
    balance: 'float',
    previousBalance: 'float',
    giftStatus: 'string'
  	/* e.g.
  	nickname: 'string'
  	*/
    
  }

};
