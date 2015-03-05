
express = require('express')
app = express()
coffeescript = require('connect-coffee-script')
sass = require('node-sass')
path = require('path')
favicon = require('serve-favicon')
global.db = require('./server/database/database')
replify = require('replify')
parser = require 'body-parser'
global.winston = require('winston')
expressWinston = require('express-winston')
rate = require 'express-rate'

production = app.get('env') != 'development'

#logging
###
logLevel = production ? 'silly' : 'info'
global.logger = new (winston.Logger)({
  transports: [
    new (winston.transports.Console)({ level: logLevel, 'timestamp':true }),
    #new (winston.transports.File)({ filename: 'somefile.log', level: 'error', 'timestamp':true})
  ]
})
###
winston.remove(winston.transports.Console)
winston.add(winston.transports.Console, {'timestamp':true})

global.logger = winston


app.use(express.compress())
app.use(parser.urlencoded({ extended: true }))
app.use(parser.json())
app.use(express.logger())


# Add headers
app.use((req, res, next) ->
  # Website you wish to allow to connect
  res.setHeader 'Access-Control-Allow-Origin', process.env.ASSETROOT || 'http://localhost:3001'
  # Request methods you wish to allow
  res.setHeader 'Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE'
  # Request headers you wish to allow
  res.setHeader 'Access-Control-Allow-Headers', 'X-Requested-With,content-type'
  # Set to true if you need the website to include cookies in the requests sent
  # to the API (e.g. in case you use sessions)
  res.setHeader 'Access-Control-Allow-Credentials', true
  # Pass to next layer of middleware
  next()
)



#request logging
app.use(expressWinston.logger({
  transports: [
    new winston.transports.Console({
      json: true,
      colorize: true
    })
  ]
}))

#rate limiting, Better to use redis if using a cluster
limiter = new rate.Memory.MemoryRateHandler()
#TODO set this up to use config settings 
limiterMiddleware = rate.middleware({handler: limiter, interval: 20, limit: 300})
#rate limit all requests for now
#app.use(limiterMiddleware)


#authentication stuff, refactor to config file in time
app.set('token_expiry', [1, 'days'])
app.use require './server/middleware/token'
require('./server/config/roles')(app)

require('./server/middleware/passport')(app)
require('./server/config/routes')(app)

logger.info("Node Env: " +  app.get('env'))
logger.log('silly', 'a silly log');

app.listen(process.env.PORT || 3000)
#replify('realtime-101', app)

global.app = module.exports = app
logger.log('Server launched in mode: ' + process.env.NODE_ENV + ' and connected to database environment: ' + process.env.DATABASE_URL);

