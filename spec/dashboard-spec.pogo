dashboard = require "../src/dashboard"
model = require "../src/model"
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
    model.Capture.find().remove()
      ready()

  describe "/exchanges/:id/responsebody"

    it "renders the response body" @(done)

      capture = new (model.Capture)
      capture.response body = new (Buffer "happy days")
      capture.response headers = {'content-type' = "text/plain"}
      capture.save
        request "#(root)/exchanges/#(capture.uuid)/responsebody" @(err, res, body)
          res.headers.'content-type'.should.equal 'text/plain'
          body.should.equal("happy days")
          done()

  escape (html) =
    html.replace r/</g '&lt;'.replace r/>/g '&gt;'

  describe "/exchanges/:id/requestbody"

    it "renders the request body" @(done)

      capture = new (model.Capture)
      capture.request body = new (Buffer "happy days")
      capture.request headers = {'content-type' = "text/plain"}
      capture.save
        request "#(root)/exchanges/#(capture.uuid)/requestbody" @(err, res, body)
          res.headers.'content-type'.should.equal 'text/plain'
          body.should.equal("happy days")
          done()

  escape (html) =
    html.replace r/</g '&lt;'.replace r/>/g '&gt;'

  describe '/exchanges/:id/responsebody/pretty, when the content is html'
    it 'renders a textarea, with the html indented' @(done)
      capture = new (model.Capture)
      capture.response body = new (Buffer "<html><head></head><body><h1>hi</h1></body></html>")
      capture.response headers = {'content-type' = "text/html"}
      capture.save
        request "#(root)/exchanges/#(capture.uuid)/responsebody/pretty" @(err, res, body)
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
      capture = new (model.Capture)
      capture.request body = new (Buffer "<html><head></head><body><h1>hi</h1></body></html>")
      capture.request headers = {'content-type' = "text/html"}
      capture.save
        request "#(root)/exchanges/#(capture.uuid)/requestbody/pretty" @(err, res, body)
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
    
      capture = new (model.Capture)
      capture.response body = new (Buffer "this is text")
      capture.response headers = {'content-type' = "text/html"}
      capture.save
        request "#(root)/exchanges/#(capture.uuid)/responsebody/html" @(err, res, body)
          res.headers.'content-type'.should.equal 'text/html; charset=utf-8'
          res.headers.'cache-control'.should.equal 'max-age=31536000 private'

          body.should.include (escape "this is text")
          done()

  describe "/exchanges/:id/requestbody/html, when the content is text"

    it "renders a textarea" @(done)
    
      capture = new (model.Capture)
      capture.request body = new (Buffer "this is text")
      capture.request headers = {'content-type' = "text/html"}
      capture.save
        request "#(root)/exchanges/#(capture.uuid)/requestbody/html" @(err, res, body)
          debugger
          res.headers.'content-type'.should.equal 'text/html; charset=utf-8'
          res.headers.'cache-control'.should.equal 'max-age=31536000 private'

          body.should.include (escape "this is text")
          done()

  describe "/exchanges/:id/responsebody/html, when the content is an image"

    it "renders an img" @(done)
      capture = new (model.Capture)
      capture.response body = new (Buffer (0))
      capture.response headers = {'content-type' = "image/png"}
      capture.save
        request "#(root)/exchanges/#(capture.uuid)/responsebody/html" @(err, res, body)
          res.headers.'content-type'.should.equal 'text/html; charset=utf-8'
          res.headers.'cache-control'.should.equal 'max-age=31536000 private'

          body.should.include("<img")
          done()

  describe "/exchanges/:id/requestbody/html, when the content is an image"

    it "renders an img" @(done)
      capture = new (model.Capture)
      capture.request body = new (Buffer (0))
      capture.request headers = {'content-type' = "image/png"}
      capture.save
        request "#(root)/exchanges/#(capture.uuid)/requestbody/html" @(err, res, body)
          res.headers.'content-type'.should.equal 'text/html; charset=utf-8'
          res.headers.'cache-control'.should.equal 'max-age=31536000 private'

          body.should.include("<img")
          done()
  
  describe "/exchanges/:id/responsebody/html, when the response resulted in an error"
    
    it "renders a generic [no response] message" @(done)
      capture = new (model.Capture)
      capture.status = -1
      capture.save
        request "#(root)/exchanges/#(capture.uuid)/responsebody/html" @(err, res, body)
          body.should.equal('<html><body><p>[no response]</p></body></html>')
          done()
  
  describe "/exchanges/:id/responsebody/html, when no response has yet been recorded"
    
    it "renders a generic [no response] message" @(done)
      capture = new (model.Capture)
      capture.save
        request "#(root)/exchanges/#(capture.uuid)/responsebody/html" @(err, res, body)
          body.should.include("[no response]")
          done()

  describe "/exchanges/summary?over=:minutes, when there is a spread of historical data"

    save a capture timed (n) seconds in the past (then carry on) =
      capture = new (model.Capture)
      capture.time = new(Date())
      capture.time = capture.time.set time(test start time - (n * 1000))
      captures.push (capture)
      capture.save (then carry on)

    save (n) capture timed (m) minutes in the past (then carry on) = 
      save (n) captures timed (m) minutes in the past (then carry on)

    save (n) captures timed (m) minutes in the past (then carry on) = 
      for (i = 1, i <= n, i = i + 1)
        save a capture timed ((m * 60) + i) seconds in the past (then carry on)

    spread captures over five minutes (then carry on) = 
      then carry on when all are saved = _.after(38, then carry on)

      save (9)  captures timed (1) minutes in the past (then carry on when all are saved)
      save (0)  captures timed (2) minutes in the past (then carry on when all are saved)
      save (25) captures timed (3) minutes in the past (then carry on when all are saved)
      save (1)  capture  timed (4) minutes in the past (then carry on when all are saved)
      save (3)  captures timed (5) minutes in the past (then carry on when all are saved)

    test start time = null
    captures = []

    round (time) to nearest second =
      time - (time % 1000)

    (n) minutes ago to nearest second =
      round (test start time - (n * 1000)) to nearest second

    before each @(ready)
      test start time = new (Date).get time()
      spread captures over five minutes
        ready()

    it "returns all captures over the supplied minutes by time descending" @(done)
      request "#(root)/exchanges/summary?over=4&now=#(test start time)" @(err, res, body)
        captures over range = JSON.parse(body)
        captures over range.length.should.equal (34)
        JSON.stringify(captures over range).should.equal(JSON.stringify(_.first(captures,34)))

        done()

