proxy = require "../src/proxy"
model = require "../src/model"

request = require "request"
http = require 'http'

describe "proxy"

  request (url) via proxy (respond) =
    options = {
      url = url
      proxy = "http://127.0.0.1:9848/"
    }
    request (options) @(err, response, body)
      if (err)
        console.log (err)
      
      respond(response, body)

  messages = []
  emit (name, data) =
    messages.push { name = name, data = data }
    
  proxy server = null
  
  before each @(ready)
    fake io = { sockets = { emit = emit } }
    proxy server = proxy.create server(fake io)
    proxy server.listen 9848
    ready()

  after each
    proxy server.close ()

  describe "proxying requests to bogus domains"
    
    it "stays alive" @(done)
      request "http://this-test-will-eventually-fail.com" via proxy @(response, body)
        done()
