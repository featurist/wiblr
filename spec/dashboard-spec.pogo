dashboard = require "../src/dashboard"
model = require "../src/model"
express = require "express"
request = require "request"
_ = require 'underscore'

describe "dashboard"

  before

    app = express.create server ()
    app.listen 9586
    dashboard.mount (app)
    
  before each @(ready)
    model.Capture.find().remove()
      ready()

  describe "/requests/:id"

    it "renders the response body" @(done)

      capture = new (model.Capture)
      capture.response body = new (Buffer ("happy days"))
      capture.content type = "text/plain"
      capture.save
        request "http://127.0.0.1:9586/requests/#(capture.uuid)" @(err, res, body)
          body.should.equal("happy days")
          done()

  describe "/requests/:id/html, when the content is text"

    it "renders a textarea" @(done)

      capture = new (model.Capture)
      capture.response body = new (Buffer ("wonder years"))
      capture.content type = "text/plain"
      capture.save
        request "http://127.0.0.1:9586/requests/#(capture.uuid)/html" @(err, res, body)
          body.should.include("<textarea")
          done()

  describe "/requests/:id/html, when the content is an image"

    it "renders an img" @(done)

      capture = new (model.Capture)
      capture.response body = new (Buffer (0))
      capture.content type = "image/png"
      capture.save
        request "http://127.0.0.1:9586/requests/#(capture.uuid)/html" @(err, res, body)
          body.should.include("<img")
          done()

  describe "/requests/summary?over=:minutes, when there is a spread of historical data"

    save a capture timed (n) seconds in the past (then carry on) =
      capture = new (model.Capture)
      capture.response body = new (Buffer (0))
      capture.content type = "text/plain"
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
      request "http://127.0.0.1:9586/requests/summary?over=4&now=#(test start time)" @(err, res, body)
        for each @(capture) in (captures)
          capture.response body = null
          
        captures over range = JSON.parse(body)
        captures over range.length.should.equal (34)
        JSON.stringify(captures over range).should.equal(JSON.stringify(_.first(captures,34)))

        done()
