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

module.exports.sendConfirmation = function(userAttrs, next){
  console.log('sending a confirmation email using the user attrs:', userAttrs)
  fs.readFile('assets/views/confirmation-email.jade', 'utf8', function (err, file) {
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


function confirmHTML(token){
  return '<html><head><title>Confirmation</title></head><body>Click this link to confirm your email: <a href="' + token + '"></a> </body></html>'
}