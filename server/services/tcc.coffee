merge = require('merge')
request = require('request')
q = require('q')

header = 
  hdr:
    'live':'',
    'fmt':'MGC',
    'ver':'1.0.0',
    'uid':process.env.TCC_UID || 'CAB44F07-5038-4576-A43C-FD1A108CDB4A',
    'cliUid':process.env.TCC_CLI_UID || '2EC26589-258A-448E-A1DA-AA0F443C5152',
    'cliId':process.env.TCC_CLI_ID || 73,
    'locId':process.env.TCC_LOC_ID || 1,
    'rcId':0,
    'term':'1',
    'srvId':518,
    'srvNm':'',
    'key':'',
    'chk':'12345'


inquiryBody = (card) ->
	merge header,
	{
    'txs': [ {
      'typ': 2
      'crd': card
      'amt': ''
    } ]
  }

#activate can also refill
activateBody = (card, amount) ->
	merge header,
 	{
    'txs': [ {
      'typ': 4
      'crd': card
      'amt': amount
    } ]
  }

redeemBody = (card, amount) ->
	merge header,
  {
    'txs': [ {
      'typ': 5
      'crd': card
      'amt': amount
    } ]
  }

createBody = (amount, program) ->
	merge header,
  {
    'txs': [ {
      'typ': 3
      'amt': amount
      'prog': program
      #'crd': "2073183100123127"
    } ]
  }

module.exports =
  createCard: (amount, program) ->
    deferred = q.defer()

    url = app.get('tccURL')
    console.log('url is' , url)
    options = 
      method: 'post'
      body: createBody(amount, program)
      json: true
      url: url
    console.log 'request to tcc for creating card is  ', options.body
    request options, (err, httpResponse, body) ->
      console.log 'res for creating card is ', body
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


  cardInfo: (card_number) ->
    deferred = q.defer()
    url = app.get('tccURL')
    options = 
      method: 'post'
      body: inquiryBody(card_number)
      json: true
      url: url
    console.log 'request to tcc is  ', options.body
    request options, (err, httpResponse, body) ->
      console.log 'res body is', body
      console.log('card header is: ', body.txs[0].hdr)
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

  #can also activate a card
  refillCard: (card_number, amount) ->
    deferred = q.defer()
    body = activateBody(card_number, amount)
    url = app.get('tccURL')
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
    url = app.get('tccURL')
    options = 
      method: 'post'
      body: redeemBody(card_number, amount)
      json: true
      url: url
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



handleError = (err, body, deferred) ->
  if err?
    deferred.reject {code: 500, name:'connectionError', error: err, message: 'Connection problem with TCC'}
  else
    deferred.reject {code: 400, name:'TCCError', error: body, message: 'TCC rejected request'}