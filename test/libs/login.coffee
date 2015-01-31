request = require("supertest")
savedSession = undefined
module.exports = (params, callback) ->
  unless savedSession
    session = request.agent(sails.express.app)
    session.post("/auth/local").send(
      email: "light24bulbs@gmail.com"
      password: "secretpassword"
    ).expect(200).end (err, res) ->
      
      #console.log('login response:', res)
      console.log "logged in to new session with response", res.body
      console.log "login err: ", err
      savedSession = session
      callback session
      return

  
  # session will manage its own cookies
  # res.redirects contains an Array of redirects
  else
    console.log "using saved session"
    callback savedSession
  return