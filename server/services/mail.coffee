
email = require('emailjs')
jade = require('jade')
fs = require('fs')
server = email.server.connect(
  user: 'deepwinterdevelopment'
  password: process.env.EMAILPASSWORD
  host: 'smtpcorp.com'
  timeout: 15000
  port: 2525)

send = (params, next) ->
  server.send params, (err, message) ->
    logger.info message
    if err
      console.log(err)
      return next err
    else
      return next()
    return

module.exports.sendConfirmation = (userAttrs, to, next) ->
  #bit of a hack to facilitate sending the confirmation to the users new email if they are updating it
  console.log 'sending a confirmation email using the user attrs:', userAttrs
  fs.readFile 'views/confirmation-email.jade', 'utf8', (err, file) ->
    if err
      return next(err)
    console.log 'read jade template file data: ', file
    template = jade.compile(file)
    link = app.get('apiRoot') + '/user/confirm?token=' + userAttrs.confirmation_token
    html = template(
      name: userAttrs.full_name
      link: link)
    mail =
      to: to or userAttrs.email
      from: 'Gift It <no-reply@gift.it>'
      text: 'Gift It email confirmation. Paste this link into your browser to confirm your email: ' + link
      attachment:
        data: html
        alternative: true
      subject: 'Diner\'s Group confirmation'
    console.log('about to send mail ', mail)
    send mail, next
    return
  return

module.exports.giftNotify = (gift, description, from, next) ->
  console.log 'sending a gift notification email'
  fs.readFile 'views/gift-email.jade', 'utf8', (err, file) ->
    if err
      return next(err)
    console.log 'read jade template file data: ', file
    template = jade.compile(file)
    link = app.get('assetRoot')
    html = template(
      from: from.get('name')
      balance: gift.get('balance')
      link: link
      description: description
    )
    mail =
      to: gift.get('to_email')
      from: 'Gift It <no-reply@gift.it>'
      text: 'You have received a Gift It gift.  Please visit the site to claim your gift: ' + link
      attachment:
        data: html
        alternative: true
      subject: 'You received a gift card'
    send mail, next
    return
  return

module.exports.sendPasswordReset = (user, token, next) ->
  console.log 'sending a password reset email'
  fs.readFile 'views/password-reset-email.jade', 'utf8', (err, file) ->
    if err
      return next(err)
    console.log 'read jade template file data: ', file
    template = jade.compile(file)
    link = app.get('assetRoot') + '#resetpassword?token=' + token.get('key')
    html = template(
      name: user.get('display_name')
      link: link)
    mail =
      to: user.get('email')
      from: 'Gift It <no-reply@gift.it>'
      text: 'Diners Group password reset.    Paste this link into your browser to reset your password: ' + link
      attachment:
        data: html
        alternative: true
      subject: 'Diner\'s Group password reset'
    send mail, next
    return
  return

module.exports.invite = (email, next) ->
  logger.info  'sending an invitation'
  fs.readFile 'views/invite-email.jade', 'utf8', (err, file) ->
    if err
      return next(err)
    console.log 'read jade template file data: ', file
    template = jade.compile(file)
    link = app.get('assetRoot')
    html = template(link: link)
    mail =
      to: email
      from: 'Gift It <no-reply@gift.it>'
      text: 'Diners Group Invitation.  Paste this link into your browser to accept your invitation: ' + link
      attachment:
        data: html
        alternative: true
      subject: 'Diner\'s Group Invite'
    console.log('about to send message: ', mail)
    send mail, next
    return
  return
