


module.exports = {

  attributes: {
  	

  	token: 'string',
    tokenSecret: 'string',
    email: 'string',
    uid: {
    	type:'string',
    	index:true
    }
  }
  
  , beforeCreate: function (attrs, next) {
  	console.log('creating authentication model instant with attrs:', attrs);
  	User.findOne({email: attrs.email}).done(function(err, user){
  		if (err) return next(err);
  		if (user){
  			//user already exists
  			console.log('found existing user for auth method ', user)
  			attrs.user_id = user._id
  			return next()
  		} else {
  			var data = {
            name: attrs.displayName
        };

        data.email = attrs.emails[0].value;
        
        if(attrs.name && attrs.name.givenName) {
            data.fistname = attrs.name.givenName;
        }
        if(attrs.name && attrs.name.familyName) {
            data.lastname = attrs.name.familyName;
        }

        User.create(data).done(function (err, user) {
        		attrs.user_id = user._id
            console.log('new user saved as: ', user);
            console.log('with error', err)
            next(err)
        });
  		}
  	});
		next();
	}
	,afterCreate: function(attrs, next){
		//console.log('aftercreate callback called with attrs: ', attrs)
		next();
	}
	 

}

