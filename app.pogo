http = require 'http'
express = require 'express'
app = express.create server ()
io = require 'socket.io'.listen (app)
url utils = require 'url'
zlib = require 'zlib'

app.use (express.static (__dirname + '/public'))
app.listen 8080

forward request (request, response, url: nil, method: 'GET', headers: {}) =
  parsed url = url utils.parse (url)
  port = parsed url.port
  host = parsed url.hostname
  path = parsed url.path || '/'
  body = ''
  
  proxy = http.create client (port, host)
  
  console.log "------------------------------------------------------------"
  console.log "forwarding #(method) request to http://#(host):#(port)#(path) with headers:"
  console.log (headers)
  
  proxy request = proxy.request (method, path, headers)
  
  proxy request.on 'response' @(proxy response)
    
    console.log "RESPONSE HEADERS"
    console.log (proxy response. headers)
    
    emit caputre () =
      io.sockets.emit 'capture' {
        time = new (Date)
        method = method
        url = url
        request headers = headers
        response headers = proxy response.headers
        body = body
      }
      
    pipe compressed () =
      
      console.log "GZIP!"
      gzip data = ''
      gunzip = zlib.create gunzip ()
      proxy response.pipe (gunzip)
      gunzip.on 'data' @(chunk)
        gzip data = gzip data + chunk.to string 'binary'
    
      gunzip.on 'end'
        body = gzip data
        response.end ()
        emit caputre ()
    
    pipe plain () =
      
      proxy response.on 'data' @(chunk)
        body = body + chunk.to string 'binary'
      
      proxy response.on 'end'
        response.end ()
        emit caputre ()
      
    proxy response.on 'data' @(chunk)
      response.write (chunk, 'binary')
    
    if (proxy response.headers.'content-encoding' == 'gzip')
      pipe compressed ()  
    else
      pipe plain ()
  
    response.write head (proxy response.status code, proxy response.headers)
  
  request.on 'data' @(chunk)
    proxy request.write (chunk, 'binary')
    
  request.on 'end'
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