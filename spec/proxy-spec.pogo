proxy = require "../src/proxy"
model = require "../src/model"

request = require "request"
http = require 'http'

describe "proxy"
  
  teapot app = http.create server @(req, res)
    headers = {}
    headers.'content-type' = "earl/grey"
    res.write head (418, headers) 
    res.end "I'm a teapot\n"

  request via proxy (respond) =
    options = {
      url = "http://127.0.0.1:9837/"
      proxy = "http://127.0.0.1:9838/"
    }
    request (options) @(err, response, body)
      if (err) @{ throw (err) }
      respond(response, body)
  
  last message = {}
  emit (name, data) =
    last message = { name = name, data = data }
  
  fake io = {
    sockets = { emit = emit }
  }
  proxy server = proxy.create server(fake io)
  
  before
    proxy server.listen 9838
    teapot app.listen 9837
  
  after
    proxy server.close ()
    teapot app.close ()
  
  it "proxies requests" @(done)
    request via proxy @(response, body)
      body.should.equal("I'm a teapot\n")
      response.status code.should.equal(418)
      response.headers.'content-type'.should.equal("earl/grey")
      done()

  it "emits socket messages" @(done) =>
    request via proxy @(response, body)
      last message.name.should.equal("capture")
      last message.data.content type.should.equal("earl/grey")
      last message.data.status.should.equal(418)
      done()

  it "saves captures" @(done)
    request via proxy @(response, body)
      model.Capture.find one { uuid = last message.data.uuid } @(err, capture)
        if (err) @{ throw (err) }
        capture.status.should.equal(418)
        done()
  