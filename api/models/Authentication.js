


module.exports = {

  attributes: {
  	

  	token: 'string',
    tokenSecret: 'string',
    email: 'string',
    uid: {
    	type:'string',
    	index:true
    },
    user_id: 'integer'

  }
  
  , beforeCreate: function (attrs, next) {
  	console.log('creating authentication model instance with attrs:', attrs);
  	User.findOne({email: attrs.email}).done(function(err, user){
  		if (err) return next(err);
  		console.log('found matching user: ', user)
  		if (user){
  			//user already exists
  			console.log('found existing user for auth method ', user)
  			attrs.user_id = user.id
  			return next()
  		} else {
  			var data = {
            name: attrs.name,
            email: attrs.email,
            firstName: attrs.firstname,
            lastName: attrs.lastname
        };
        User.create(data).done(function (err, user) {
        		attrs.user_id = user.id
            console.log('new user saved as: ', user);
            console.log('with error', err)
            console.log('and the auth attributes before save are: ', attrs)
            next(err)
        });
  		}
  	});
	}
	,afterCreate: function(attrs, next){
		//console.log('aftercreate callback called with attrs: ', attrs)
		next();
	}
	 

}

