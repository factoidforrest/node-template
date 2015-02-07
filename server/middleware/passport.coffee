passport = require("passport")

#    , GitHubStrategy = require('passport-github').Strategy
#    , FacebookStrategy = require('passport-facebook').Strategy
###
GoogleStrategy = require("passport-google-oauth").OAuth2Strategy
FacebookStrategy = require("passport-facebook").Strategy

LocalStrategy = require("passport-local").Strategy

TwitterStrategy = require("passport-twitter").Strategy
###
GoogleAuthCodeStrategy = require('passport-google-authcode').Strategy



passport.use new GoogleAuthCodeStrategy({
  #vars should be out of source and in the environment
  clientID: "808716966460-mu0tt4jvafitf5vvf2rolj2dpjfvdrba.apps.googleusercontent.com"
  clientSecret: "NBZ-UcUjZsXrUB3CCod-m-Ww"
}, (accessToken, refreshToken, profile, done) ->
  console.log('got profile from google:', profile)
  Authentication.findOrCreateGoogle accessToken, refreshToken, profile, (err, user) ->
    done err, user
)
###
#this handler is used for third party authentications like google
verifyHandler = (accessToken, refreshToken, params, profile, done) ->
  console.log params
  console.log "the user profile is: ", profile
  process.nextTick ->
    Authentication.findOne(uid: profile.id).done (err, authentication) ->
      if authentication
        console.log "updating this existing authentication with new auth information", authentication
        authentication.token = accessToken
        authentication.refreshToken = refreshToken
        authentication.googleParams = params
        authentication.save (err) ->
          User.findOne
            id: authentication.user_id
          , (err, user) ->
            if err
              console.log "authentication saving error ", err
              return done(err)
            console.log "authentication updated to db"
            done null, user

          return

      else
        console.log "creating new authentication from auth data"
        data =
          provider: profile.provider
          uid: profile.id
          name: profile.displayName

        
        #may need to make 100% sure they have an email for this to work right
        data.email = profile.emails[0].value  if profile.emails and profile.emails[0] and profile.emails[0].value
        data.firstname = profile.name.givenName  if profile.name and profile.name.givenName
        data.lastname = profile.name.familyName  if profile.name and profile.name.familyName
        data.token = accessToken
        data.refreshToken = refreshToken
        console.log "the authentication data is", data
        
        #creating an authentication will automatically create a user if none exists with that email, see auth model
        Authentication.create(data).done (err, authentication) ->
          User.findOne
            id: authentication.user_id
          , (err, user) ->
            console.log "new authentication saved as: ", authentication
            console.log "with user:", user
            console.log "with error", err
            done err, user

          return

      return

    return

  return



passport.serializeUser (user, done) ->
  console.log "serializing user: ", user
  
  #we have the user model which means we are authenticating using a password
  id = user.get('id')
  done null, id
  return

passport.deserializeUser (id, done) ->
  User.where(id: id).fetch().then((user) ->
    done null, user
    return
  ).catch (err) ->
    logger.error('failed to deserialize user with id', id, 'and error' , err)
    done err, null
###
# Init custom express middleware
module.exports = (app) ->
  
  #ssl stuff

    
    #            passport.use(new GitHubStrategy({
    #                    clientID: "YOUR_CLIENT_ID",
    #                    clientSecret: "YOUR_CLIENT_SECRET",
    #                    callbackURL: "http://localhost:1337/auth/github/callback"
    #                },
    #                verifyHandler
    #            ));
    #
    #            passport.use(new FacebookStrategy({
    #                    clientID: "YOUR_CLIENT_ID",
    #                    clientSecret: "YOUR_CLIENT_SECRET",
    #                    callbackURL: "http://localhost:1337/auth/facebook/callback"
    #                },
    #                verifyHandler
    #            ));
  
  #DEPRECATED, local auth just runs directly in controller now
  ###
  passport.use new LocalStrategy(
    usernameField: "email"
    passwordField: "password"
  
  #,passReqToCallback : true
  , localHandler)
  
  #is it a good idea to have these vars in source or should they be in env vars?
  facebookOptions =
    clientID: "302044043323057"
    clientSecret: "e34b95e000707d104a318a36ea587b8a"
    
    #this is going to need to be set by a config var but sails.config isn't accessible
    #here so we made need a trick or to read the env variable off of the app object
    callbackURL: "https://localhost:1337/auth/facebook/callback"

  passport.use new FacebookStrategy(facebookOptions, verifyHandler)
  
  passport.use new TwitterStrategy(
    consumerKey: "Bs8rkqXa7lFTpngp6mtrYQHtN"
    consumerSecret: "XUTGiBfCsvk6PF4H0P0tYgyopE3DLDnO2WREl1uLBVeiYMXNoL"
    callbackURL: "https://localhost:1337/auth/twitter/callback"
  , verifyHandler)
  passport.use new GoogleStrategy(
    clientID: "525376363568-p6rb6mji0mpj4f6otog4b81pgeni631i.apps.googleusercontent.com"
    clientSecret: "0IsST81_2uT2okOcgTxpzgcE"
    callbackURL: "https://localhost:1337/auth/google/callback"
  
  #                    callbackURL: 'http://api.mobilegiftcard.com/auth/google/callback'
  , verifyHandler)
  ###
  app.use passport.initialize()
  #app.use passport.session()
  return

#
#            app.post('/auth/local', function(req, res){
#              console.log("body parsing", req.body);
#              //should be something like: {username: YOURUSERNAME, password: YOURPASSWORD}
#            });
#            