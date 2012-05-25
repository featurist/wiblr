express = require 'express'
proxy = require './proxy'
dashboard = require "./dashboard"
stache = require 'stache'

app = require './app'.create app ()
io = require 'socket.io'.listen (app)

proxy port = 8081
dashboard port = 8080

proxy.create server (io).listen (proxy port)
app.listen (dashboard port)
console.log "proxy: http://localhost:#(proxy port)/"
console.log "dashboard: http://localhost:#(dashboard port)/"
