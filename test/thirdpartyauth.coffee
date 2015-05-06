request = require('supertest');
setup = require('./libs/setup')
expect = require('chai').expect
userLib = require('./libs/user')

key = null
googleToken= 'ya29.YQGsIcdZjLE0PkBarNRWvRnDVeh1wC5dbfNlklVwuxEk2i4HkYL2wWh0G3R9hFIhfzGm6xJl6MUTkw' # ya29.GwFbNhm2pVQjNPDXw9SmvozWQ1HjhBQ2z6sKkOvfifPO9ugyx7Zxl_lwHb1mVVMXmv_W_R4JL5Jg_w'
googleRefresh= '1/pEBrMtmF-qJEdRUDQsMFgzwB8UoN58kxJTSLH-pMIlEMEudVrK5jSpoR30zcRFq6'#1/og6EOVAm_JL-8AOCZYktYSpW4WzfIAMGmlGcBtFlbd0MEudVrK5jSpoR30zcRFq6'
googleOneTimeToken = 'ya29.ZAFjB2dh68Cc8REjf5rSrUnCJYfAjw_cTbV6r8cv-uqGTkmCoyqzOrQT-dTY5mFwKLbi-YyLlmeA0w'
facebookToken= 'CAAEuSSIjkhoBAGr3ZAmtyU9LZBPKSMmtKZAQH9xqfISHqf6y1DC0Yu4t3lwZCYZC4MPL4gN6hzOoBye2fSCwUb3a8ZAMazga5ZAWBXZAr4Lv6F2uxmeJbCUvxxqUZCNQIJjGqx5eRxZA43CTkmZApgZCO1y4VfEYhPbZBCsDaaN47muybsWIKQ39y24ZAvOfJkQ1SZA6HgCflAb0HNHbO4XFe6yGtGBM9PwvHQHBIkZD'

describe 'third party auth', ()->
	
	it 'test google api with new auth', (done) ->
		this.timeout 15000
		Authentication.findOrCreateGoogle(
			googleToken,
			googleRefresh,
			(err, user) ->
				console.log('got err ', err)
				console.log('got user from auth google create', user)
				expect(user).to.exist
				done(err)
		)

	it 'test google api with already existing auth', (done) ->
		this.timeout 15000
		Authentication.findOrCreateGoogle(
			googleToken,
			googleRefresh,
			(err, user) ->
				console.log('got err ', err)
				console.log('got user from auth google create', user)
				expect(user).to.exist
				done(err)
		)

	it 'google api with one time token', (done) ->
		this.timeout 15000
		session = request.agent(app)
		session.post("/auth/google/clientside")
		.send(one_time_token:googleOneTimeToken )
		.expect(200)
		.end (err, res) ->
			console.log('got response for one time token login: ', res.body)
			done(err)


	it 'test google signin using mobile gift card api', (done) ->
		this.timeout(15000)
		session = request.agent(app)
		session.post("/auth/google/clientside").send(
			access_token: googleToken
			refresh_token: googleRefresh
		).expect(200).end (err, res) ->
			
			#console.log('login response:', res)
			console.log "google signed in with response", res.body
			console.log "login err: ", err
			expect(res.body.token.key).to.exist
			key = res.body.token.key
			done(err)

	it 'token return from google signin should be valid', (done) ->
		this.timeout 15000
		session = request.agent(app)
		session.post("/user/testtoken").send({
			token: key
		}).expect(200).end (err, res) ->
			
			#console.log('login response:', res)
			console.log('authenticated with token and got response:', res.body)
			done(err)
	
	it 'should communicate directly with facebook', (done)->
		token = 'CAAEuSSIjkhoBAPHohne0NsSEktpcCAy5RVqvgYZCIzQBTtNuj3UsgIuLR0b12o6INZBCOKtUVVcT8IAUAbyd2Tj4LRKdn5Qoo0nwBlgAIhB2zrJx2T3vgaoIy4q2IOUYI6EGyc44LLqtW2xS30W6eOUzZBzkNC6tqzcH143QBrJxCCRRmIJUM2ZA05pLeoTNCx67gxD7joJUGSZCxW40aOQiJYeBhGfsZD'
		Authentication.findOrCreateFacebook token, (err, user) ->
			console.log('findorcreatefacebook returned error: ', err)
			done(err)

	it 'test facebook signin using mobile gift card api', (done) ->
		this.timeout(15000)
		session = request.agent(app)
		session.post("/auth/facebook/clientside").send(
			access_token: googleToken
		).expect(200).end (err, res) ->
			
			#console.log('login response:', res)
			console.log "facebook signed in with response", res.body
			console.log "login err: ", err
			expect(res.body.token.key).to.exist
			key = res.body.token.key
			done(err)

	it 'facebook signin should handle bad facebook token', (done) ->
		token = "abc"
		session = request.agent(app)
		session.post("/auth/facebook/clientside").send(
			access_token: token
		).expect(200).end (err, res) ->
			
			#console.log('login response:', res)
			console.log "bad facebook signed in with response", res.body
			console.log "login err: ", err
			expect(res.body.token.key).to.not.exist
			done(err)
