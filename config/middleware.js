var passport = require('passport')
//    , GitHubStrategy = require('passport-github').Strategy
//    , FacebookStrategy = require('passport-facebook').Strategy
    , GoogleStrategy = require('passport-google-oauth').OAuth2Strategy
    , FacebookStrategy = require('passport-facebook').Strategy
    , LocalStrategy = require('passport-local').Strategy;

var verifyHandler = function (accessToken, refreshToken, params, profile, done) {
    console.log(params);
    process.nextTick(function () {
        User.findOne({uid: profile.id}).done(function (err, user) {
            if (user) {
                console.log('updating existing user with new auth information', user)
                user.token = accessToken;
                user.refreshToken = refreshToken;
                user.googleParams = params;
                user.save(function(err) {
                    if (err) {
                        console.log("user saving error ", err);
                    }
                    console.log('user updated to db')
                });
                return done(null, user);
            } else {
                console.log('creating new user from auth data')
                var data = {
                    provider: profile.provider,
                    uid: profile.id,
                    name: profile.displayName
                };

                if(profile.emails && profile.emails[0] && profile.emails[0].value) {
                    data.email = profile.emails[0].value;
                }
                if(profile.name && profile.name.givenName) {
                    data.fistname = profile.name.givenName;
                }
                if(profile.name && profile.name.familyName) {
                    data.lastname = profile.name.familyName;
                }

                data.token = accessToken;
                data.refreshToken = refreshToken;
                console.log('the user data is', data)
                User.create(data).done(function (err, user) {
                    console.log('new user saved as: ', user);
                    console.log('with error', err)
                    return done(err, user);
                });
            }
        });
    });
};

var localHandler = function(username, password, done){
    User.findOne({ username: username }, function(err, user) {
      if (err) { return done(err); }
      if (!user) {
        return done(null, false, { message: 'Incorrect username.' });
      }
      if (!user.validPassword(password)) {
        return done(null, false, { message: 'Incorrect password.' });
      }
      return done(null, user);
    });
}

passport.serializeUser(function (user, done) {
    console.log('serializing user: ', user)
    done(null, user.uid);
});

passport.deserializeUser(function (uid, done) {
    User.findOne({uid: uid}).done(function (err, user) {
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

            passport.use(new LocalStrategy(localHandler));

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

        }
    }

};
