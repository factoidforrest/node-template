
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
expressWinston = require('express-winston');

production = app.get('env') != 'development'

#logging

logLevel = production ? 'silly' : 'info'
global.logger = new (winston.Logger)({
  transports: [
    new (winston.transports.Console)({ level: logLevel }),
    #new (winston.transports.File)({ filename: 'somefile.log', level: 'error' })
  ]
})

app.use(express.compress())
app.use(parser.urlencoded({ extended: true }))
app.use(parser.json())
app.set('views', __dirname + '/views')
app.use(express.logger())
app.use(favicon(path.join(__dirname,'public','images','favicon.ico')))
app.locals.uglify = production

app.set('view engine', 'jade')

app.use(sass.middleware({
  src: __dirname + '/views/stylesheets',
  dest: __dirname + '/public',
  debug: !production,
  outputStyle: if production then 'compressed' else 'nested'
}))

#TODO: switch to a compiler with compression support or maybe not and just have require minifier do it later
app.use(coffeescript({
  src: __dirname + '/views/js',
  dest: __dirname + '/public',
  bare: true,
  compress: production
}))

if production
	cachetime = 86400000
else
	cachetime = 0

#static assets
app.use(express.static(__dirname + '/public', { maxAge: cachetime }))


#request logging
app.use(expressWinston.logger({
  transports: [
    new winston.transports.Console({
      json: true,
      colorize: true
    })
  ]
}));
 
###
#root
app.get('/', handlers.root)

#api
app.post('/locations', handlers.locations)
###
require('./server/middleware/passport')(app)
require('./server/config/routes')(app)

logger.info("Node Env: " +  app.get('env'))
logger.log('silly', 'a silly log')

app.listen(process.env.PORT || 3000)
#replify('realtime-101', app)

module.exports = app

