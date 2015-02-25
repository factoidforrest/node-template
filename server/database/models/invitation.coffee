Mail = require '../../services/mail'

module.exports = (bookshelf) ->
	global.Invitation = bookshelf.Model.extend({
		tableName: 'invitations'
		hasTimestamps: true
		
		sender: ->
			return @belongsTo(User, 'sender_id')

	},{
			#class methods
		invite: (email, from, done) ->
			Invitation = this
			User.forge(email:email).fetch().then (existingUser) ->
				if existingUser?
					return done({name:'alreadyJoined', message: 'This user has already joined'})
				invite = Invitation.forge(email: email)
				invite.fetch().then (existingInvitation) ->
					if existingInvitation?
						return done {name: 'alreadyInvited', message: 'This user has already been invited to join' }
					invite.set(sender_id: from.get('id'))
					invite.save().then (saved) ->
						Mail.invite saved.get('email'), (err) ->
							if err?
								logger.error(err)
						done(err, saved)
	})
	return Invitation
