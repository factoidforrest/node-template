

objectAssign = require('object-assign')

hooksCreated = false

module.exports.createHooks = (params) ->
	unless hooksCreated
	  before (done) ->
	    module.exports.createUser params, done
	    registeredDestroyHook = true


module.exports.createUser = (params, done) ->
  userProperties = 
    email: 'light24bulbs@gmail.com'
    last_name: 'testLast'
    full_name: 'testFirst testLast'
    provider: 'local'
    first_name: 'testFirst'
  objectAssign userProperties, params
  User.create(userProperties).then (user) ->
    user.set('confirmation_token', null)
    #need to do this in it's own step so it doesn't trigger password confirmation via email
    user.setPassword 'secretpassword', ->
      user.save (err, user) ->
        #console.log('created user for testing:', user)
        if err
          return done(err)
        done()
        return
      return
    return
  return

module.exports.manuallyDestroyUser = (done) ->
  User.destroy {}, ->
    console.log 'destroyed all users'
    done()
    return
  return

module.exports.getUser = () ->
  User.where(email: 'light24bulbs@gmail.com').fetch()

###
module.exports.getUser = function getUser(params, cb){

  User.findOne({first_name: 'testFirst'}).exec(function(err, user){
    if(JSON.stringify(params) !== JSON.stringify({})) {
      return cb(err, user)
    } else {
      //modify the user using the params, save the user, and return it
    }

  });
}

###

# ---
# generated by js2coffee 2.0.0