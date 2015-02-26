braintree = require 'braintree'

class Braintree

	constructor: () ->
		logger.info 'constructing brain tree class'
		@gateway = gateway = braintree.connect
		  environment: braintree.Environment.Sandbox
		  merchantId: "krz4wwwqtz422wd2"
		  publicKey: "s9gcngjrhsb3hjk2"
		  privateKey: "bcb24b71fcdcc8c583306dae35d77128"

	generateClientToken: (done) ->
		@gateway.clientToken.generate {}, (err, response) -> 
			if err?
				return done({code: 500, name: 'BTErr', message: 'Error contacting payment server', error: err})
		  clientToken = response.clientToken
		  return done(null, clientToken)


	pay: (amount, nonce, done) ->
		gateway.transaction.sale {
		  amount: amount
		  paymentMethodNonce: nonce
		  options: {
			# submitForSettlement: true  Actually collect the payment
			}
		},  (err, result) ->
			console.log('payment completed with err: ', err, ' and result: ', result)
			if !result.success
				return done({code:400, name:'TransactionErr', message: ('Transaction failed: ', result.transaction.status), transaction: result.transaction})
				for error in result.errors.deepErrors() 
					console.log('transaction error: ', error.message, ' full error: ', error)
			done(err, result)


#pretty sure this caches the export for multiple requires
module.exports = new Braintree()