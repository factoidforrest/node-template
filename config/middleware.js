var passport = require('passport')
//    , GitHubStrategy = require('passport-github').Strategy
//    , FacebookStrategy = require('passport-facebook').Strategy
    , GoogleStrategy = require('passport-google-oauth').OAuth2Strategy;


var verifyHandler = function (accessToken, refreshToken, params, profile, done) {
    console.log(params);
    process.nextTick(function () {
        User.findOne({uid: profile.id}).done(function (err, user) {
            if (user) {
                user.token = accessToken;
                user.refreshToken = refreshToken;
                user.googleParams = params;
                user.save(function(err) {
                    if (err) {
                        console.log("BOO: ", err);
                    }
                });
                return done(null, user);
            } else {

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

                User.create(data).done(function (err, user) {
                    return done(err, user);
                });
            }
        });
    });
};

passport.serializeUser(function (user, done) {
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

            passport.use(new GoogleStrategy({
                    clientID: '200927102479-37l48tk8uamrushob22ff8rg9dv9kl4n.apps.googleusercontent.com',
                    clientSecret: 'lhpefdZAZQry95cokNDHj7DR',
                    callbackURL: 'http://localhost:1337/auth/google/callback',
                },
                verifyHandler
            ));

            app.use(passport.initialize());
            app.use(passport.session());
        }
    }

};
