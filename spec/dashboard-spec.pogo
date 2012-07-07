dashboard = require "../src/dashboard"
Exchange = require '../src/models/exchange'
express = require "express"
request = require "request"
_ = require 'underscore'

describe "dashboard"

  root = nil

  before
    app = require '../src/app'.create app ()
    app.listen 9586
    root = 'http://localhost:9586'

  before each @(ready)
    Exchange.find().remove()
      ready()

  describe "/exchanges/:id/responsebody"

    it "renders the response body" @(done)

      exchange = new (Exchange)
      exchange.response body = new (Buffer "happy days")
      exchange.response headers = {'content-type' = "text/plain"}
      exchange.save
        request "#(root)/exchanges/#(exchange.uuid)/responsebody" @(err, res, body)
          res.headers.'content-type'.should.equal 'text/plain'
          body.should.equal("happy days")
          done()

  escape (html) =
    html.replace r/</g '&lt;'.replace r/>/g '&gt;'

  describe "/exchanges/:id/requestbody"

    it "renders the request body" @(done)

      exchange = new (Exchange)
      exchange.request body = new (Buffer "happy days")
      exchange.request headers = {'content-type' = "text/plain"}
      exchange.save
        request "#(root)/exchanges/#(exchange.uuid)/requestbody" @(err, res, body)
          res.headers.'content-type'.should.equal 'text/plain'
          body.should.equal("happy days")
          done()

  escape (html) =
    html.replace r/</g '&lt;'.replace r/>/g '&gt;'

  describe '/exchanges/:id/responsebody/pretty, when the content is html'
    it 'renders a textarea, with the html indented' @(done)
      exchange = new (Exchange)
      exchange.response body = new (Buffer "<html><head></head><body><h1>hi</h1></body></html>")
      exchange.response headers = {'content-type' = "text/html"}
      exchange.save
        request "#(root)/exchanges/#(exchange.uuid)/responsebody/pretty" @(err, res, body)
          res.headers.'content-type'.should.equal 'text/html; charset=utf-8'
          res.headers.'cache-control'.should.equal 'max-age=31536000 private'

          body.should.include (escape "<html>
                                         <head></head>
                                         <body>
                                           <h1>hi</h1>
                                         </body>
                                       </html>")
          done()

  describe '/exchanges/:id/requestbody/pretty, when the content is html'
    it 'renders a textarea, with the html indented' @(done)
      exchange = new (Exchange)
      exchange.request body = new (Buffer "<html><head></head><body><h1>hi</h1></body></html>")
      exchange.request headers = {'content-type' = "text/html"}
      exchange.save
        request "#(root)/exchanges/#(exchange.uuid)/requestbody/pretty" @(err, res, body)
          res.headers.'content-type'.should.equal 'text/html; charset=utf-8'
          res.headers.'cache-control'.should.equal 'max-age=31536000 private'

          body.should.include (escape "<html>
                                         <head></head>
                                         <body>
                                           <h1>hi</h1>
                                         </body>
                                       </html>")
          done()

  describe "/exchanges/:id/responsebody/html, when the content is text"

    it "renders a textarea" @(done)
    
      exchange = new (Exchange)
      exchange.response body = new (Buffer "this is text")
      exchange.response headers = {'content-type' = "text/html"}
      exchange.save
        request "#(root)/exchanges/#(exchange.uuid)/responsebody/html" @(err, res, body)
          res.headers.'content-type'.should.equal 'text/html; charset=utf-8'
          res.headers.'cache-control'.should.equal 'max-age=31536000 private'

          body.should.include (escape "this is text")
          done()

  describe "/exchanges/:id/requestbody/html, when the content is text"

    it "renders a textarea" @(done)
    
      exchange = new (Exchange)
      exchange.request body = new (Buffer "this is text")
      exchange.request headers = {'content-type' = "text/html"}
      exchange.save
        request "#(root)/exchanges/#(exchange.uuid)/requestbody/html" @(err, res, body)
          debugger
          res.headers.'content-type'.should.equal 'text/html; charset=utf-8'
          res.headers.'cache-control'.should.equal 'max-age=31536000 private'

          body.should.include (escape "this is text")
          done()

  describe "/exchanges/:id/responsebody/html, when the content is an image"

    it "renders an img" @(done)
      exchange = new (Exchange)
      exchange.response body = new (Buffer (0))
      exchange.response headers = {'content-type' = "image/png"}
      exchange.save
        request "#(root)/exchanges/#(exchange.uuid)/responsebody/html" @(err, res, body)
          res.headers.'content-type'.should.equal 'text/html; charset=utf-8'
          res.headers.'cache-control'.should.equal 'max-age=31536000 private'

          body.should.include("<img")
          done()

  describe "/exchanges/:id/requestbody/html, when the content is an image"

    it "renders an img" @(done)
      exchange = new (Exchange)
      exchange.request body = new (Buffer (0))
      exchange.request headers = {'content-type' = "image/png"}
      exchange.save
        request "#(root)/exchanges/#(exchange.uuid)/requestbody/html" @(err, res, body)
          res.headers.'content-type'.should.equal 'text/html; charset=utf-8'
          res.headers.'cache-control'.should.equal 'max-age=31536000 private'

          body.should.include("<img")
          done()
  
  describe "/exchanges/:id/responsebody/html, when the response resulted in an error"
    
    it "renders a generic [no response] message" @(done)
      exchange = new (Exchange)
      exchange.status = -1
      exchange.save
        request "#(root)/exchanges/#(exchange.uuid)/responsebody/html" @(err, res, body)
          body.should.equal('<html><body><p>[no response]</p></body></html>')
          done()
  
  describe "/exchanges/:id/responsebody/html, when no response has yet been recorded"
    
    it "renders a generic [no response] message" @(done)
      exchange = new (Exchange)
      exchange.save
        request "#(root)/exchanges/#(exchange.uuid)/responsebody/html" @(err, res, body)
          body.should.include("[no response]")
          done()

  describe "/exchanges/summary?over=:minutes, when there is a spread of historical data"

    save a exchange timed (n) seconds in the past (then carry on) =
      exchange = new (Exchange)
      exchange.time = new (Date)
      exchange.time = exchange.time.set time(test start time - (n * 1000))
      exchanges.push (exchange)
      exchange.save (then carry on)

    save (n) exchange timed (m) minutes in the past (then carry on) = 
      save (n) exchanges timed (m) minutes in the past (then carry on)

    save (n) exchanges timed (m) minutes in the past (then carry on) = 
      for (i = 1, i <= n, i = i + 1)
        save a exchange timed ((m * 60) + i) seconds in the past (then carry on)

    spread exchanges over five minutes (then carry on) = 
      then carry on when all are saved = _.after(38, then carry on)

      save (9)  exchanges timed (1) minutes in the past (then carry on when all are saved)
      save (0)  exchanges timed (2) minutes in the past (then carry on when all are saved)
      save (25) exchanges timed (3) minutes in the past (then carry on when all are saved)
      save (1)  exchange  timed (4) minutes in the past (then carry on when all are saved)
      save (3)  exchanges timed (5) minutes in the past (then carry on when all are saved)

    test start time = null
    exchanges = []

    round (time) to nearest second =
      time - (time % 1000)

    (n) minutes ago to nearest second =
      round (test start time - (n * 1000)) to nearest second

    before each @(ready)
      test start time = new (Date).get time()
      spread exchanges over five minutes
        ready()

    it "returns all exchanges over the supplied minutes by time descending" @(done)
      request "#(root)/exchanges/summary?over=4&now=#(test start time)" @(err, res, body)
        exchanges over range = JSON.parse(body)
        exchanges over range.length.should.equal (34)
        JSON.stringify(exchanges over range).should.equal(JSON.stringify(_.first(exchanges,34)))

        done()

