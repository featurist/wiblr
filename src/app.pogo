express = require 'express'
dashboard = require "./dashboard"
stache = require 'stache'
compiler = require 'connect-compiler'
engines = require 'consolidate'
require 'hogan'

exports.create app () =
  app = express()
  app.configure 'development'
    app.use (compiler {
      enabled = ['less']
      src = 'src/public'
      dest = 'src/public'
    })
  
  app.use (express.static (__dirname + '/public'))
  app.set('views', __dirname + '/views')
  app.set('view engine', 'html')
  app.engine('html', require('hogan-express'))
  dashboard.mount (app)
  app
