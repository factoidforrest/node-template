var email, failHTML, server, successHTML;

email = require("emailjs");

server = email.server.connect({
  user: "deepwinterdevelopment",
  password: process.env.EMAILPASSWORD,
  host: "smtpcorp.com",
  timeout: 15000,
  port: 2525
});

var send = module.exports.send = function(params, next) {
  return server.send({
    text: params.message,
    from: params.from,
    to: params.to,
    subject: params.subject
  }, function(err, message) {
    console.log(err || message);
    if (err) {
      next(err)
    } else {
      next()
    }
  });
};

module.exports.sendConfirmation = function(userAttrs, next){
  mail = {
    to: userAttrs.email,
    from: 'no-reply@dinersgroup.com',
    message: 'Non HTML body',
    attachment:  {data:"<html>i <i>hope</i> this works!</html>", alternative:true},//confirmHTML(userAttrs.token),
    subject: "Diner's Group confirmation"
  }

  send(mail, next)
}


function confirmHTML(token){
  return '<html><head><title>Confirmation</title></head><body>Click this link to confirm your email: <a href="' + token + '"></a> </body></html>'
}