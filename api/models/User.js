

var bcrypt = require("bcrypt-nodejs")

module.exports = {

  attributes: {
  	

    tokenSecret: 'string',
    password: 'string',
    email: {
      type: 'email', // Email type will get validated by the ORM
      index: true
    },
    token: 'string',

    validPassword: function(password) {
      console.log('checking password')
      //would be more efficient to do this async, can figure that out once load becomes a problem
      var valid = false;
      valid = bcrypt.compareSync(password, this.password)
      console.log('correct password? : ', valid)
      return valid;
    },
    setPassword: function(password, next){
      var self = this;
      if (password.length < 6){
        return next('Password too short')
      }
      bcrypt.hash(password, null, null, function (err, hash) {
        if (err) return next(err);
        self.password = hash;
        return next();
      });
    },
    toJSON: function() {
      return {
            created_at: this.createdAt,
            email: this.email,
            id: this.id,
            last_name: this.lastname,
            full_name: this.name,
            provider: this.provider,
            uid: this.uid,
            updated_at: this.updatedAt,
            first_name: this.firstname,
            email: this.email,
            admin: this.admin
        }
    }
    
  }, 
  confirmEmail: function(token, next){
    console.log('searching for user with token:', token)
    User.findOne({token:token}).done(function(err, user){
      if (err) return next(err);
      if (user === null || typeof(user) === 'undefined') return next('Invalid token');
      console.log('found user to confirm by token: ', user)
      if (user.token === null) {
        return next('This user is already confirmed, please log in.')
      }
      //swap with new email if the user was updating an existing email
      if (user.hasOwnProperty('new_email')){
        user.email = user.new_email;
      }

      user.token = null;
      user.save(function(error){
        if (error) return next(error);
        console.log('updated user to remove token: ', user);
        next();
      });
    });
  }
  
  , beforeCreate: function (attrs, next) {

    console.log('user before create called and the attributes are')
    console.log(attrs)
    //bcrypt = require("bcrypt")
    //User.findByEmail(attrs.email).done(function(err, user){
    //  console.log('found users matching email: ', user)
    //});
    if (typeof(attrs.password) !== 'undefined'){//(attrs.strategy === 'local'){
      console.log("converting password to hash");
      bcrypt.hash(attrs.password, null, null, function (err, hash) {
        if (err) return next(err);
        attrs.password = hash;
        delete(attrs.passwordConfirmation);
        //should check the key is unique but it's probably ok not to since the chances of two being the same are insanely small
        require('crypto').randomBytes(48, function(ex, buf) {
          attrs.token = buf.toString('hex');
          Mail.sendConfirmation(attrs, next);
        });
        
      });

    } else {
      next();
    }
  }
	,afterCreate: function(attrs, next){
		next();
	}
	 

}

