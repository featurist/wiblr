http = require 'http'
express = require 'express'
app = express: create server!
io = require 'socket.io': listen (app)

app: use (express: static (__dirname + '/public'))
app: listen 8080

http: create server @(request, response)
  proxy = http: create client (80, request: headers: host)
  io: sockets: emit 'capture' {
    time = new (Date)
    method = request: method
    url = request: url
    headers = request: headers
  }
  proxy request = proxy: request (request:method, request:url, request:headers)
  proxy request: add listener 'response' @(proxy response)
    proxy response: add listener 'data' @(chunk) @{ response: write (chunk, 'binary') }
    proxy response: add listener 'end' @{ response: end! }
    response: write head (proxy response: status code, proxy response: headers)
  
  request: add listener 'data' @(chunk) @{ proxy request: write (chunk, 'binary') }
  request: add listener 'end' @{ proxy request: end! }  
:listen 8081