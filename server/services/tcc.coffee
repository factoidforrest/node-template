merge = require('merge')
request = require('request')
q = require('q')

header = (clientId, locationId) ->
  hdr:
    'live':'',
    'fmt':'MGC',
    'ver':'1.0.0',
    #partner ID
    'pauid': process.env.TCC_PARTNER_ID || 'CAB44F07-5038-4576-A43C-FD1A108CDB4A',
    #client ID
    'mauid': clientId || '01685DF1-3D7A-46D6-BB2C-EEFE632015CC',
    'locId': locationId || 1, 
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
    'key':''
    #REMOVED CHECK NUMBER TO SEE WHAT HAPPENS
    #'chk':'12345'


inquiryBody = (number, clientId) ->
	merge header(clientId),
	{
    'txs': [ {
      'typ': 2
      'crd': number
      'amt': ''
    } ]
  }

#activate can also refill
activateBody = (number, clientId, locationId, amount) ->
	merge header(clientId),
 	{
    'txs': [ {
      'typ': 4
      'crd': number
      'amt': amount
    } ]
  }

redeemBody = (number, clientId, locationId, amount) ->
	merge header(clientId, locationId),
  {
    'txs': [ {
      'typ': 5
      'crd': number
      'amt': amount
    } ]
  }

createBody = (amount, clientId) ->
  #THIS NEEDS TO HANDLE LOCATION AS WELL, FOR NOW JUST USING 1  !!!!!! or maybe it doesn't matter
	merge header(clientId),
  {
    'txs': [ {
      'typ': 3
      'amt': amount
      #'prog': program
    } ]
  }

voidBody = (card, serial) ->
  merge header(card.related('program').get('client_id')),
  {
    'txs': [ {
      'typ': 6
      'crd': card.get('number')
      'ser': serial
    } ]
  }

module.exports =
  createCard: (amount, clientId) ->
    deferred = q.defer()

    url = app.get('tccURL') + '/ProcessJson'
    console.log('url is' , url)
    options = 
      method: 'post'
      body: createBody(amount, clientId)
      json: true
      url: url
    console.log 'request to tcc for creating card is  ', options.body
    request options, (err, httpResponse, body) ->
      console.log 'res for creating card is ', body
      if body.txs[0]? then console.log 'card header is ', body.txs[0].hdr
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


  cardInfo: (card) ->
    deferred = q.defer()
    url = app.get('tccURL') + '/ProcessJson'
    options = 
      method: 'post'
      body: inquiryBody(card.get('number'), card.get('client_id'))
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
  refillCard: (card_number, client_id, location_id, amount) ->
    console.log('refilling card $', amount)
    deferred = q.defer()
    body = activateBody(card_number, client_id, location_id, amount)
    url = app.get('tccURL') + '/ProcessJson'
    options = 
      method: 'post'
      body: body
      json: true
      url: url
    console.log 'request to tcc for refilling card is  ', options.body
    request options, (err, httpResponse, body) ->
      if err or body.txs.length == 0
        return handleError(err, body, deferred)
      txn = body.txs[0]
      deferred.resolve
        card_number: txn.crd
        status: txn.crdStat
        balance: txn.bal
        previousBalance: txn.prevBal
        serial: txn.hdr.ser
      return
    deferred.promise




  redeemCard: (card_number, client_id, location_id, amount) ->
    deferred = q.defer()
    url = app.get('tccURL') + '/ProcessJson'
    options = 
      method: 'post'
      body: redeemBody(card_number, client_id, location_id, amount)
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
        serial: txn.hdr.ser
      return
    deferred.promise

  void: (card, serial, done) ->
    card.load('program').then (card) ->
      url = app.get('tccURL') + '/ProcessJson'
      options = 
        method: 'post'
        body: voidBody(card, serial)
        json: true
        url: url
      console.log 'request to void card:  ', options.body
      request options, (err, httpResponse, body) ->
        logger.info('TCC response voiding card: ', body)
        console.log(body)
        if err? || body.hdr.rslt != 1
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
      logger.log('tcc responded with programs: ', body)
      if err? || !body.pa?
        return done({code:500, name: 'TCCErr', message: 'Failed to get program list from tcc.', error: err, response: httpResponse, body: body})
      done(null, body.pa)




handleError = (err, body, deferred) ->
  if err?
    deferred.reject {code: 500, name:'connectionError', error: err, message: 'Connection problem with TCC'}
  else
    deferred.reject {code: 400, name:'TCCError', error: body, message: 'TCC rejected request'}