express = require 'express'
proxy = require './proxy'
dashboard = require "./dashboard"
stache = require 'stache'
compiler = require 'connect-compiler'

exports.create app () =
  app = express.create server ()
  app.use (express.logger())
  
  app.configure 'development'
    app.use (compiler {
      enabled = ['less']
      src = 'src/public'
      dest = 'src/public'
      log_level = "DEBUG"
    })
  
  app.use (express.static (__dirname + '/public'))
  app.set('views', __dirname + '/views')
  app.set('view engine', 'html')
  app.register('.html', stache)
  dashboard.mount (app)
  app
