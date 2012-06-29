proxy = require "../src/proxy"
model = require "../src/model"

request = require "request"
http = require 'http'
should = require 'should'
freeport = require 'freeport'

describe "proxy"

  request (url) via proxy (respond) =
    options = {
      url = url
      proxy = "http://featurist:cats@127.0.0.1:9848/"
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
      freeport @(error, port)
        request "http://localhost:#(port)" via proxy @(response, body)
          should.not.exist(body)
          done()
