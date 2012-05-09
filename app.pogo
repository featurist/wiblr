http = require 'http'
express = require 'express'
app = express.create server ()
io = require 'socket.io'.listen (app)
url utils = require 'url'

app.use (express.static (__dirname + '/public'))
app.listen 8080

forward request (request, response, url: nil, method: 'GET', headers: {}) =
  parsed url = url utils.parse (url)
  port = parsed url.port
  host = parsed url.hostname
  path = parsed url.path || '/'
  
  proxy = http.create client (port, host)

  io.sockets.emit 'capture' {
    time = new (Date)
    method = method
    url = url
    headers = headers
  }

  console.log "forwarding #(method) request to http://#(host):#(port)#(path) with headers:"
  console.log (headers)
  
  proxy request = proxy.request (method, path, headers)

  proxy request.add listener 'response' @(proxy response)
    proxy response.add listener 'data' @(chunk)
      response.write (chunk, 'binary')
    
    proxy response.add listener 'end'
      response.end ()
        
    response.write head (proxy response.status code, proxy response.headers)
  
  request.add listener 'data' @(chunk)
    proxy request.write (chunk, 'binary')
    
  request.add listener 'end'
    proxy request.end ()

http.create server @(request, response)
  forward url = url utils.parse (request.url)

  forward request (
    request
    response
    url: request.url
    method: request.method
    headers: request.headers
  )
.listen 8081