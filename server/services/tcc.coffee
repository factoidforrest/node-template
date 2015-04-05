merge = require('merge')
request = require('request')
q = require('q')

header = (clientId) ->
  hdr:
    'live':'',
    'fmt':'MGC',
    'ver':'1.0.0',
    #partner ID
    'pauid': process.env.TCC_PARTNER_ID || 'CAB44F07-5038-4576-A43C-FD1A108CDB4A',
    #client ID
    'mauid': clientId || '01685DF1-3D7A-46D6-BB2C-EEFE632015CC',
    'locId': 1, 
    ###
    'uid':process.env.TCC_UID || 'CAB44F07-5038-4576-A43C-FD1A108CDB4A',
    'cliUid':process.env.TCC_CLI_UID || '2EC26589-258A-448E-A1DA-AA0F443C5152',
    'cliId':process.env.TCC_CLI_ID || 73,
    'locId':process.env.TCC_LOC_ID || 1,
    ###
    'rcId':0,
    'term':'1',
    'srvId':518,
    'srvNm':'',
    'key':'',
    'chk':'12345'


inquiryBody = (card, clientId) ->
	merge header(clientId),
	{
    'txs': [ {
      'typ': 2
      'crd': card
      'amt': ''
    } ]
  }

#activate can also refill
activateBody = (card, clientId, amount) ->
	merge header(clientId),
 	{
    'txs': [ {
      'typ': 4
      'crd': card
      'amt': amount
    } ]
  }

redeemBody = (card, clientId, amount) ->
	merge header(clientId),
  {
    'txs': [ {
      'typ': 5
      'crd': card
      'amt': amount
    } ]
  }

createBody = (amount, clientId, program) ->
	merge header(clientId),
  {
    'txs': [ {
      'typ': 3
      'amt': amount
      'prog': program
      #'crd': "2073183100123127"
    } ]
  }

voidBody = (card) ->
  merge header(null),#card.get('client_id')),
  {
    'txs': [ {
      'typ': 6
      'crd': card.get('number')
      'ser': card.get('serial')
    } ]
  }

module.exports =
  createCard: (amount, program) ->
    deferred = q.defer()

    url = app.get('tccURL') + '/ProcessJson'
    console.log('url is' , url)
    options = 
      method: 'post'
      body: createBody(amount, null, program)
      json: true
      url: url
    console.log 'request to tcc for creating card is  ', options.body
    request options, (err, httpResponse, body) ->
      console.log 'res for creating card is ', body
      console.log 'card header is ', body.txs[0].hdr
      if err or body.txs.length == 0
        return handleError(err, body, deferred)
      console.log 'resolving promise'
      txn = body.txs[0]
      deferred.resolve
        card_number: txn.crd
        status: txn.crdStat
        balance: txn.bal
        previousBalance: txn.prevBal
        serial: txn.hdr.ser
      return
    deferred.promise


  cardInfo: (card_number) ->
    deferred = q.defer()
    url = app.get('tccURL') + '/ProcessJson'
    options = 
      method: 'post'
      body: inquiryBody(card_number)
      json: true
      url: url
    console.log 'request to tcc is  ', options.body
    request options, (err, httpResponse, body) ->
      logger.info 'tcc res body is', body
      if err or body.txs.length == 0
        return handleError(err, body, deferred)
      console.log('card header is: ', body.txs[0].hdr)

      console.log 'resolving promise'
      txn = body.txs[0]
      deferred.resolve
        card_number: txn.crd
        status: txn.crdStat
        balance: txn.bal
        previousBalance: txn.prevBal
      return
    deferred.promise

  #can also activate a card
  refillCard: (card_number, amount) ->
    deferred = q.defer()
    body = activateBody(card_number, amount)
    url = app.get('tccURL') + '/ProcessJson'
    options = 
      method: 'post'
      body: body
      json: true
      url: url
    request options, (err, httpResponse, body) ->
      if err or body.txs.length == 0
        return handleError(err, body, deferred)
      txn = body.txs[0]
      deferred.resolve
        card_number: txn.crd
        status: txn.crdStat
        balance: txn.bal
        previousBalance: txn.prevBal
      return
    deferred.promise




  redeemCard: (card_number, amount) ->
    deferred = q.defer()
    url = app.get('tccURL') + '/ProcessJson'
    options = 
      method: 'post'
      body: redeemBody(card_number, null, amount)
      json: true
      url: url
    console.log 'request to tcc for redeeming card is  ', options.body
    request options, (err, httpResponse, body) ->
      console.log 'res body is', body
      if err or body.txs.length == 0
        return handleError(err, body, deferred)
      console.log 'resolving promise'
      txn = body.txs[0]
      deferred.resolve
        card_number: txn.crd
        status: txn.crdStat
        balance: txn.bal
        previousBalance: txn.prevBal
      return
    deferred.promise

  voidCard: (card, done) ->
    url = app.get('tccURL') + '/ProcessJson'
    options = 
      method: 'post'
      body: redeemBody(card_number, null, amount)
      json: true
      url: url
    console.log 'request to void card:  ', options.body
    request options, (err, httpResponse, body) ->
      if err? 
        return done({code:500, name: 'TCCErr', message: 'Failed to void card.', error: err, response: httpResponse, body: body})
      done()


  getPrograms: (done) ->
    url = app.get('tccURL') + '/WLapiAdmInqJson'
    programBody = {
      'pauid': process.env.TCC_PARTNER_ID || 'CAB44F07-5038-4576-A43C-FD1A108CDB4A'
      'ser':'654321'
    }
    options = 
      method: 'post'
      body: programBody
      json: true
      url: url
    console.log('making request with options ', options)
    request options, (err, httpResponse, body) ->

      if err? || !body.pa?
        return done({code:500, name: 'TCCErr', message: 'Failed to get program list from tcc.', error: err, response: httpResponse, body: body})
      done(null, body.pa)




handleError = (err, body, deferred) ->
  if err?
    deferred.reject {code: 500, name:'connectionError', error: err, message: 'Connection problem with TCC'}
  else
    deferred.reject {code: 400, name:'TCCError', error: body, message: 'TCC rejected request'}