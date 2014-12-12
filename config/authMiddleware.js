var passport = require('passport')
//    , GitHubStrategy = require('passport-github').Strategy
//    , FacebookStrategy = require('passport-facebook').Strategy
    , GoogleStrategy = require('passport-google-oauth').OAuth2Strategy
    , FacebookStrategy = require('passport-facebook').Strategy
    , LocalStrategy = require('passport-local').Strategy;

//this handler is used for third party authentications like google
var verifyHandler = function (accessToken, refreshToken, params, profile, done) {
    console.log(params);
    process.nextTick(function () {
        Authentication.findOne({uid: profile.id}).done(function (err, authentication) {
            if (authentication) {
                console.log('updating this existing authentication with new auth information', authentication)
                authentication.token = accessToken;
                authentication.refreshToken = refreshToken;
                authentication.googleParams = params;

                authentication.save(function(err) {
                    if (err) {
                        console.log("authentication saving error ", err);
                    }
                    console.log('authentication updated to db')
                });
                return done(null, authentication);
            } else {
                console.log('creating new authentication from auth data')
                var data = {
                    provider: profile.provider,
                    uid: profile.id,
                    name: profile.displayName
                };

                //may need to make 100% sure they have an email for this to work right
                if(profile.emails && profile.emails[0] && profile.emails[0].value) {
                    data.email = profile.emails[0].value;
                }
                if(profile.name && profile.name.givenName) {
                    data.firstname = profile.name.givenName;
                }
                if(profile.name && profile.name.familyName) {
                    data.lastname = profile.name.familyName;
                }

                data.token = accessToken;
                data.refreshToken = refreshToken;
                console.log('the authentication data is', data)
                Authentication.create(data).done(function (err, authentication) {
                    console.log('new authentication saved as: ', authentication);
                    console.log('with error', err)
                    return done(err, authentication);
                });
            }
        });
    });
};

var localHandler = function(email, password, done){
    console.log('finding local user to authenticate: ', email)
    User.findOne({ email: email }, function(err, user) {
        console.log('localhandler found one user', user)
        console.log('and an err of:', err)
      if (err) { return done(err); }
      if (!user) {
        return done(null, false, { message: 'Incorrect email.' });
      }
      
      if (!user.validPassword(password)) {
        return done(null, false, { message: 'Incorrect password.' });
      }
      return done(null, user);
    });
}

passport.serializeUser(function (authentication, done) {
    console.log('serializing authentication: ', authentication)
    console.log('with user: ', authentication.user_id)
    if (authentication.provider) {
        //we have an authentication model(facebook, twitter, etc)
        id = authentication.user_id;
    }  else {
        //we have the user model which means we are authenticating using a password
        id = authentication.id;
    }

    done(null, id);
});

passport.deserializeUser(function (id, done) {
    User.findOne({id: id}).done(function (err, user) {
        console.log('found user using session key: ', user)
        done(err, user)
    });
});


module.exports = {

    // Init custom express middleware
    express: {
        
        customMiddleware: function (app) {

//            passport.use(new GitHubStrategy({
//                    clientID: "YOUR_CLIENT_ID",
//                    clientSecret: "YOUR_CLIENT_SECRET",
//                    callbackURL: "http://localhost:1337/auth/github/callback"
//                },
//                verifyHandler
//            ));
//
//            passport.use(new FacebookStrategy({
//                    clientID: "YOUR_CLIENT_ID",
//                    clientSecret: "YOUR_CLIENT_SECRET",
//                    callbackURL: "http://localhost:1337/auth/facebook/callback"
//                },
//                verifyHandler
//            ));

            passport.use(new LocalStrategy(
                { 
                    usernameField : 'email', 
                    passwordField : 'password'
                    //,passReqToCallback : true
                },
                localHandler));
   
            //is it a good idea to have these vars in source or should they be in env vars?
            var facebookOptions = {
                clientID: '302044043323057',
                clientSecret: 'e34b95e000707d104a318a36ea587b8a',
                //this is going to need to be set by a config var but sails.config isn't accessible
                //here so we made need a trick or to read the env variable off of the app object
                callbackURL: 'http://localhost:1337/auth/facebook/callback'
            }

            passport.use(new FacebookStrategy(facebookOptions,  verifyHandler));

            passport.use(new GoogleStrategy({
                    clientID: '200927102479-37l48tk8uamrushob22ff8rg9dv9kl4n.apps.googleusercontent.com',
                    clientSecret: 'lhpefdZAZQry95cokNDHj7DR',
                    callbackURL: 'http://localhost:1337/auth/google/callback',
//                    callbackURL: 'http://api.mobilegiftcard.com/auth/google/callback'
                },
                verifyHandler
            ));

            app.use(passport.initialize());
            app.use(passport.session());

            /*
            app.post('/auth/local', function(req, res){
              console.log("body parsing", req.body);
              //should be something like: {username: YOURUSERNAME, password: YOURPASSWORD}
            });
            */
        }
    }

};
