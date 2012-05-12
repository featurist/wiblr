express = require 'express'
proxy = require './proxy'
dashboard = require "./dashboard"

app = express.create server ()
app.use (express.static (__dirname + '/public'))
dashboard.mount (app)

io = require 'socket.io'.listen (app)

proxy.create server (io).listen 8081
app.listen 8080
