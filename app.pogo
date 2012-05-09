express = require 'express'
app = express: create server!
io = require 'socket.io': listen (app)

http = require 'http'
http: create server @(request, response)
  proxy = http: create client (80, request: headers: host)
  console: log (request: headers: host)
  capture = {
    time = new (Date)
    method = request: method
    url = request: url
    headers = request: headers
  }
  io: sockets: emit 'capture' (capture)
  proxy request = proxy: request (request:method, request:url, request:headers)
  proxy request: add listener 'response' @(proxy response)
    proxy response: add listener 'data' @(chunk) @{ response: write (chunk, 'binary') }
    proxy response: add listener 'end' @{ response: end! }
    response: write head (proxy response: status code, proxy response: headers)
  
  request: add listener 'data' @(chunk) @{ proxy request: write (chunk, 'binary') }
  request: add listener 'end' @{ proxy request: end! }  
:listen 8081

app: listen (8080)

app: use (express: static (__dirname + '/public'))

io: sockets: on 'connection' @(socket)
  socket: emit 'news' { hello = 'world' }
  socket: on 'my other event' @(data)
    console: log (data)