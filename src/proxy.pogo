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
  
  capture = new (model.Capture)
  capture.time = new (Date)
  capture.method = method
  capture.protocol = parsed url.protocol.replace r/:$/ ''
  capture.url = url
  capture.host = host
  capture.path = path
  capture.request headers = request.headers
  capture.response body = new (Buffer [])
  
  emit capture() = 
    io.sockets.emit 'capture' (capture.wire object())
  
  save capture() =
    capture.save @(error)
      if (error) @{ console.log (error) }
      emit capture()   
      delete (capture)
  
  save capture()
  
  proxy = http.create client (port, host)
  // console.log (method, path, headers)
  proxy request = proxy.request (method, path, headers)

  request.on 'data' @(chunk)
    proxy request.write (chunk, 'binary')
    
  request.on 'end'
    proxy request.end ()
 
  proxy.on 'error' @(error)
    true // proxy _request_ error doesn't fire without this
        
  proxy request.on 'error' @(error)
    capture.status = -1
    save capture()
    response.end()
 
  proxy request.on 'response' @(proxy response)

    request complete() =
      response.end()
      save capture()
      
    proxy response.on 'data' @(chunk)
      response.write (chunk, 'binary')
      
    capture.content type = proxy response.headers.'content-type'
    capture.response headers = proxy response.headers
    capture.status = proxy response.status code

    copy response data (chunk) =
      capture.append response body (chunk)

    unzip () =
      gzip data = ''
      gunzip = zlib.create unzip ()
      proxy response.pipe (gunzip)
      gunzip.on 'data' (copy response data)
      gunzip.on 'end' (request complete)

    plain () =
      proxy response.on 'data' (copy response data)
      proxy response.on 'end' (request complete)

    if (proxy response.headers.'content-encoding' == 'gzip')
      unzip ()  
    else
      plain ()

    response.write head (proxy response.status code, proxy response.headers)

exports.create server(io) =
  
  authenticate request (request, response) then (respond) =
    header = request.headers.'proxy-authorization' || ''
    token = header.split(r/\s+/).pop() || ''
    auth = new (Buffer(token, 'base64')).to string()
    parts = auth.split(r/:/)
    username = parts.0
    password = parts.1
    
    if ((username == 'featurist') || (password == 'cats'))    
      response.cooki
      respond()
    else
      response.header 'Proxy-Authenticate' 'Basic realm="Please enter your Wiblr account details to continue"'
      response.write head 407
      response.end "Please enter your Wiblr account details to continue"
  
  http.create server @(request, response)
    authenticate request (request, response) then
      if (request.url.match (r/^http/))
        forward request (
          io
          request
          response
          url: request.url
          method: request.method
          headers: request.headers
        )
      else
        response.end "Coming soon!"
