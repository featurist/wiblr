http = require 'http'
url utils = require 'url'
zlib = require 'zlib'
buffertools = require "buffertools"
model = require './model'

forward request (io, request, response, url: nil, method: 'GET', headers: {}) =
  
  parsed url = url utils.parse (url) 
  port = parsed url.port
  host = parsed url.hostname
  path = parsed url.path || '/'
  
  //console.log "forwarding #(method) request to http://#(host):#(port)#(path)"
  
  proxy = http.create client (port, host)
  proxy request = proxy.request (method, path, headers)
  
  request.on 'data' @(chunk)
    proxy request.write (chunk, 'binary')
    
  request.on 'end'
    proxy request.end ()
  
  proxy request.on 'response' @(proxy response)
  
    proxy response.on 'data' @(chunk)
      response.write (chunk, 'binary')

    capture = new (model.Capture)
    capture.content type = proxy response.headers.'content-type'
    capture.time = new (Date)
    capture.method = method
    capture.host = host
    capture.path = path
    capture.response body = new (Buffer [])
    capture.response headers = proxy response.headers
    capture.request headers = request.headers
    capture.status = proxy response.status code
    
    emit capture () =
      response.end ()
      capture.save @(error)
        if (error) @{ console.log (error) }
        io.sockets.emit 'capture' (capture.wire object())
        delete (capture)
    
    copy response data (chunk) =
      capture.append response body (chunk)
    
    unzip () =
      gzip data = ''
      gunzip = zlib.create unzip ()
      proxy response.pipe (gunzip)
      gunzip.on 'data' (copy response data)
      gunzip.on 'end' (emit capture)
    
    plain () =
      proxy response.on 'data' (copy response data)
      proxy response.on 'end' (emit capture)
    
    if (proxy response.headers.'content-encoding' == 'gzip')
      unzip ()  
    else
      plain ()
  
    response.write head (proxy response.status code, proxy response.headers)


exports.create server(io) =
 
  http.create server @(request, response)
    forward request (
      io
      request
      response
      url: request.url
      method: request.method
      headers: request.headers
    )