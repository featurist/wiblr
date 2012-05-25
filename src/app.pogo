express = require 'express'
proxy = require './proxy'
dashboard = require "./dashboard"
stache = require 'stache'

exports.create app () =
  app = express.create server ()
  app.use (express.static (__dirname + '/public'))
  app.set('views', __dirname + '/views')
  app.set('view engine', 'html')
  app.register('.html', stache)
  dashboard.mount (app)
  app
