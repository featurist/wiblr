express = require 'express'
http = require 'http'

proxy = require './proxy'
dashboard = require './dashboard'

app = require './app'.create app ()
server = http.create server(app)
io = require 'socket.io'.listen (server)

proxy port = 8081
dashboard port = 8080

proxy.create server (io).listen (proxy port)
app.listen (dashboard port)
console.log "proxy: http://localhost:#(proxy port)/"
console.log "dashboard: http://localhost:#(dashboard port)/"
