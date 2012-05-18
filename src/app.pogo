express = require 'express'
proxy = require './proxy'
dashboard = require "./dashboard"

app = express.create server ()
app.use (express.static (__dirname + '/public'))
dashboard.mount (app)

io = require 'socket.io'.listen (app)

proxy port = 8081
dashboard port = 8080

proxy.create server (io).listen (proxy port)
app.listen (dashboard port)
console.log "proxy: http://localhost:#(proxy port)/"
console.log "dashboard: http://localhost:#(dashboard port)/"