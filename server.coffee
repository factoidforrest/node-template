
express = require('express')
app = express()
coffeescript = require('connect-coffee-script')
handlers = require('./server/handlers')
sass = require('node-sass')
path = require('path')
favicon = require('serve-favicon')
db = require('./server/database/database')
replify = require('replify')
parser = require 'body-parser'

production = app.get('env') == 'production'

app.use(express.compress())
app.use(parser.urlencoded({ extended: true }))
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

#root
app.get('/', handlers.root)

#api
app.post('/locations', handlers.locations)



app.set('db', db)

console.log("Node Env: ", app.get('env'))

app.listen(process.env.PORT || 3000)
#replify('realtime-101', app)

module.exports = app

