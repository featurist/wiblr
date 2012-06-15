proxy = require "../src/proxy"
model = require "../src/model"

request = require "request"
http = require 'http'

describe "proxy"
  
  teapot app = http.create server @(req, res)
    headers = {}
    headers.'content-type' = "earl/grey"
    set
      res.write head (418, headers) 
      res.end "I'm a teapot\n"
    timeout (10)

  request via proxy (respond) =
    options = {
      url = "http://127.0.0.1:9837/teapot"
      proxy = "http://127.0.0.1:9838/"
    }
    request (options) @(err, response, body)
      if (err) @{ throw (err) }
      respond(response, body)

  emit (name, data) =
    messages.push { name = name, data = data }
    
  proxy server = null
  
  messages = []
  
  beforeEach @(ready)
    fake io = { sockets = { emit = emit } }
    proxy server = proxy.create server(fake io)
    
    proxy server.listen 9838
    teapot app.listen 9837
    
    ready()

  afterEach
    proxy server.close ()
    teapot app.close ()

  time now() =
    new (Date()).getTime()
  
  wait for (n) messages then (callback) or timeout after (milliseconds) =
    wait until 
      messages.length >= n 
    then (callback) or timeout at (time now() + milliseconds)

  wait until (predicate) then (callback) or timeout at (time) = 
    if (predicate())
      callback()
    else
      if (time now() > time)
        console.log("Timeout waiting for messages")
        throw "Timeout waiting for messages"

      set
        wait until (predicate) then (callback) or timeout at (time)
      timeout (1)

  describe "proxying requests"
    
    response = null
    body = null
  
    beforeEach @(ready)
      messages = []
      response = null
      body = null
      request via proxy @(r, b)
        response = r
        body = b
        wait for 2 messages then
          ready()
        or timeout after(200)

    it "proxies requests" @(done)
      body.should.equal "I'm a teapot\n"
      response.status code.should.equal 418
      response.headers.'content-type'.should.equal "earl/grey"
      done()

    describe "socket messages"

      the (message) should have request data = 
        message.name.should.equal("capture")
        message.data.path.should.equal('/teapot')
        message.data.method.should.equal('GET')

      it "emits a message as the request is made" @(done)
        first message = messages.0
        the (first message) should have request data
        (first message.data.response headers == undefined).should.equal(true)
        done()

      it "emits a message as the response completes" @(done)
        second message = messages.1
        the (second message) should have request data
        second message.data.status.should.equal 418
        second message.data.response headers.'content-type'.should.equal "earl/grey"
        done()

      it "saves captures" @(done)
        model.Capture.find one { uuid = messages.1.data.uuid } @(err, capture)
          if (err) @{ throw (err) }
          capture.status.should.equal 418
          capture.content type.should.equal "earl/grey"
          capture.response headers.'content-type'.should.equal "earl/grey"
          done()

  it "stays alive when accessed directly" @(done)
    request { method = "GET", url = "http://127.0.0.1:9838/" } @(err, response, body)
      if (err) @{ throw ("Failed to GET " + err.to string()) }
      body.should.equal("Coming soon!")
      request via proxy @(response, body)
        body.should.equal "I'm a teapot\n"
        done()
