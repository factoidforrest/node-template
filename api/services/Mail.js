var email, failHTML, server, successHTML;

email = require("emailjs");
var jade = require('jade');
var fs = require('fs');



server = email.server.connect({
  user: "deepwinterdevelopment",
  password: process.env.EMAILPASSWORD,
  host: "smtpcorp.com",
  timeout: 15000,
  port: 2525
});

var send = module.exports.send = function(params, next) {
  return server.send(params, function(err, message) {
    console.log(err || message);
    if (err) {
      next(err)
    } else {
      next()
    }
  });
};

module.exports.sendConfirmation = function(userAttrs, next, to){

  //bit of a hack to facilitate sending the confirmation to the users new email if they are updating it
  if (!!to) {
    userAttrs.email = userAttrs.new_email;
  }
  console.log('sending a confirmation email using the user attrs:', userAttrs)
  fs.readFile('views/confirmation-email.jade', 'utf8', function (err, file) {
    if (err) return next(err);
    console.log('read jade template file data: ', file);
    var template = jade.compile(file);
    var link = sails.config.apiRoot + 'auth/confirm?token=' + userAttrs.token;
    var html = template({
      name: userAttrs.full_name,
      link: link
    });
    mail = {
      to: userAttrs.email,
      from: 'no-reply@dinersgroup.com',
      text: 'You have HTML disabled in your email client.  Paste this link into your browser to confirm your email: ' + link,
      attachment:  {data:html, alternative:true},//confirmHTML(userAttrs.token),
      subject: "Diner's Group confirmation"
    }

    send(mail, next)
  });
}


module.exports.sendPasswordReset = function(user, token, next){
  console.log('sending a password reset email')

  fs.readFile('views/password-reset-email.jade', 'utf8', function (err, file) {
    if (err) return next(err);
    console.log('read jade template file data: ', file);
    var template = jade.compile(file);
    var link = sails.config.assetRoot + '#resetpassword?token=' + token.key;
    var html = template({
      name: user.full_name,
      link: link
    });
    mail = {
      to: user.email,
      from: 'no-reply@dinersgroup.com',
      text: 'Diners Group password reset.  You have HTML disabled in your email client.  Paste this link into your browser to reset your password: ' + link,
      attachment:  {data:html, alternative:true},//confirmHTML(userAttrs.token),
      subject: "Diner's Group password reset"
    }

    send(mail, next)
  });
}

module.exports.invite = function(email, next){
  sails.log('info','sending an invitation');

  fs.readFile('views/invite-email.jade', 'utf8', function (err, file) {
    if (err) return next(err);
    console.log('read jade template file data: ', file);
    var template = jade.compile(file);
    var link = sails.config.assetRoot;
    var html = template({
      link: link
    });
    mail = {
      to: email,
      //consider using the inviters email since that will help get around spam filters I think
      from: 'no-reply@dinersgroup.com',
      text: 'Diners Group Invitation.  You have HTML disabled in your email client.  Paste this link into your browser to accept your invitation: ' + link,
      attachment:  {data:html, alternative:true},//confirmHTML(userAttrs.token),
      subject: "Diner's Group Invite"
    }

    send(mail, next)
  });
}


