braintree = require 'braintree'

class Payment

	constructor: () ->
		#logger.info 'constructing brain tree class'
		@gateway = gateway = braintree.connect
			environment: braintree.Environment.Sandbox
			merchantId: "krz4wwwqtz422wd2"
			publicKey: "s9gcngjrhsb3hjk2"
			privateKey: "bcb24b71fcdcc8c583306dae35d77128"


	generateClientToken: (done) ->
		@gateway.clientToken.generate {}, (err, response) -> 
			logger.info('token retrieval completed with err: ', err, ' and result: ', response)
			if err? || !response.success
				return done({code: 500, name: 'BTErr', message: 'Error contacting payment server', error: err })
			clientToken = response.clientToken
			return done(null, clientToken)


	authorize: (amount, nonce, done) ->
		@gateway.transaction.sale {
			amount: amount
			paymentMethodNonce: nonce
			###
			options: {
			 submitForSettlement: true  Actually collect the payment
			}
			###
		},  (err, result) ->
			logger.info('payment authorization completed with err: ', err, ' and result: ', result)
			#TODO clean up this error handling somehow
			if err?
				return done({code:400, name:'TransactionErr', message: ('Transaction authorization failed: ' + err), transaction: result})

			if !result.success
				return done({code:400, errors: result.errors.deepErrors(), name:'TransactionErr', message: ('Transaction authorization failed: ' + result), transaction: result.transaction})
			done(err, result)

	settle: (transaction, done) ->
		@gateway.transaction.submitForSettlement transaction.id, (err, settlement) ->
			logger.info('payment settlement completed with err ', err, ' and response ', settlement)
			if err?
				return done({code:400, name:'TransactionErr', message: ('Transaction settlement failed: ' + err), transaction: settlement})
			if !settlement.success?
				return done({code:400, errors: result.errors.deepErrors(), name:'TransactionErr', message: ('Transaction settlement failed: ' + settlement.transaction.status), transaction: settlement})
			done(err, settlement)


#pretty sure this caches the export for multiple requires
module.exports = new Payment()