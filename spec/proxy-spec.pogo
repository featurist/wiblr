proxy = require "../src/proxy"
model = require "../src/model"
should = require "should"
express = require 'express'
connect = require 'connect'
zlib = require 'zlib'
teapot = require './support/teapot'

request = require "request"
http = require 'http'

(n)ms = n
after (milliseconds, action) =
  set timeout (action, milliseconds)

describe "proxy"

  request via proxy (respond, body: nil, method: 'GET', headers: {}, url: "http://127.0.0.1:9837/teapot") =
    options = {
      url = url
      method = method
      body = body
      proxy = "http://featurist:cats@127.0.0.1:9838/"
      headers = headers
    }
    request (options) @(err, response, body)
      if (err) @{ throw (err) }
      respond(response, body)

  emit (name, data) =
    messages.push { name = name, data = data }
    
  proxy server = null
  messages = nil
  teapot app = nil
  
  beforeEach @(ready)
    fake io = { sockets = { emit = emit } }
    proxy server = proxy.create server(fake io)
    
    proxy server.listen 9838
    teapot app = teapot.create teapot app ()
    teapot app.listen 9837
    
    messages = []
    
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
        throw (new (Error "Timeout waiting for messages"))

      after (1ms)
        wait until (predicate) then (callback) or timeout at (time)

  load saved exchange (done) =
    model.Capture.find one { uuid = messages.1.data.uuid } (done)

  describe "proxying requests"
    
    response = null
    body = null
  
    before each @(ready)
      response = null
      body = null
      request via proxy @(r, b)
        response = r
        body = b
        wait for 2 messages then
          ready()
        or timeout after (200ms)

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

      it "emits a message as the request is made"
        first message = messages.0
        the (first message) should have request data
        (first message.data.response headers == undefined).should.equal(true)

      it "emits a message as the response completes"
        second message = messages.1
        the (second message) should have request data
        second message.data.status.should.equal 418
        second message.data.response headers.'content-type'.should.equal "earl/grey"

    it "saves reqeust response exchange" @(done)
      load saved exchange @(err, exchange)
        if (err) @{ done (err) }
        exchange.status.should.equal 418
        exchange.response headers.'content-type'.should.equal "earl/grey"
        exchange.response body.to string ().should.equal "I'm a teapot\n"
        exchange.content length.should.equal(13)
        done()

  describe 'saving captures'
    make request (done, options) =
      request via proxy
        wait for 2 messages then (done) or timeout after (200ms)
      (options)

    it 'saves response body on GET requests' @(done)
      make request
        load saved exchange @(error, exchange)
          if (error) @{ done (error) }

          exchange.response body.to string ().should.equal "I'm a teapot\n"

          done ()

    it 'saves request and response body on POST requests' @(done)
      make request (method: 'POST', body: 'this is the body')
        load saved exchange @(error, exchange)
          if (error) @{ done (error) }

          exchange.response body.to string ().should.equal "I'm a teapot\n"
          exchange.request body.to string ().should.equal "this is the body"
          
          done ()

    it 'saves response body in plain text, even when response was gzipped' @(done)
      make request (headers: {"Accept-Encoding" = "gzip"}, url: 'http://127.0.0.1:9837/teapot_gzip')
        load saved exchange @(error, exchange)
          if (error) @{ done (error) }

          exchange.response body.to string ().should.equal "I'm a teapot\n"

          done ()

    it 'saves request body in plain text, even when request was gzipped' @(done)
      zlib.gzip 'hello world' @(error, gzipped body)
        if (error) @{ done (error) }

        make request (headers: {"Content-Encoding" = "gzip"}, url: 'http://127.0.0.1:9837/teapot_gzip', body: gzipped body)
          load saved exchange @(error, exchange)
            if (error) @{ done (error) }

            exchange.request body.to string ().should.equal "hello world"

            done ()

  it "stays alive when accessed directly" @(done)
    request { method = "GET", url = "http://127.0.0.1:9838/", proxy = "http://featurist:cats@127.0.0.1:9838/" } @(err, response, body)
      if (err) @{ throw ("Failed to GET " + err.to string()) }
      body.should.equal("Coming soon!")
      request via proxy @(response, body)
        body.should.equal "I'm a teapot\n"
        done()
