http = require 'http'
url utils = require 'url'
zlib = require 'zlib'
buffertools = require "buffertools"
model = require './model'
Memory Stream = require 'memorystream'

create memory stream () = new (Memory Stream (null, readable: false))

(request) is compressed =
  r/gzip|deflate/.test (request.headers.'content-encoding')

(req res) body stream =
  stream = create memory stream ()

  if ((req res) is compressed)
    unzip = zlib.create unzip ()
    req res.pipe (unzip)
    unzip.pipe (stream)
  else
    req res.pipe (stream)

  stream
  

forward request (io, request, response, url: nil, method: 'GET', headers: {}) =
  
  parsed url = url utils.parse (url) 
  port = parsed url.port
  host = parsed url.hostname
  path = parsed url.path || '/'
  
  capture = new (model.Capture)
  capture.time = new (Date)
  capture.method = method
  capture.protocol = parsed url.protocol.replace r/:$/ ''
  capture.url = url
  capture.host = host
  capture.path = path
  capture.request headers = request.headers
  capture.request body = new (Buffer [])
  capture.response body = new (Buffer [])
  
  emit capture() = 
    io.sockets.emit 'capture' (capture.wire object())
  
  save capture() =
    capture.save @(error)
      if (error) @{ console.log (error) }
      emit capture()   
      delete (capture)
  
  save capture()
  
  proxy request = http.request {port = port, host = host, method = method, path = path, headers = headers} @(proxy response)
    proxy response.pipe (response)
    response body stream = (proxy response) body stream

    capture.response headers = proxy response.headers
    capture.status = proxy response.status code

    response body stream.on 'end'
      capture.set response body (response body stream.to buffer ())
      capture.request body = request body stream.to buffer ()
      response.end()
      save capture()

    response.write head (proxy response.status code, proxy response.headers)

  request body stream = (request) body stream
  request.pipe (proxy request)

  proxy request.on 'error' @(error)
    capture.status = -1
    save capture()
    response.end()

exports.create server(io, ssl options) =
  
  authenticate request (request, response) then (respond) =
    header = request.headers.'proxy-authorization' || ''
    token = header.split(r/\s+/).pop() || ''
    auth = new (Buffer(token, 'base64')).to string()
    parts = auth.split(r/:/)
    username = parts.0
    password = parts.1
    
    if ((username == 'featurist') || (password == 'cats'))    
      respond()
    else
      response.write head (407, 'Proxy-Authenticate': 'Basic realm="Please enter your Wiblr account details to continue"')
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
