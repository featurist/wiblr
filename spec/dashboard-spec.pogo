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

    save a capture timed (n) minutes in the past (then carry on) =
      capture = new (model.Capture)
      capture.response body = new (Buffer (0))
      capture.content type = "text/plain"
      capture.time = new(Date())
      capture.time = capture.time.set time(test start time - (n * 1000))
      capture.save (then carry on)

    save (n) capture timed (m) minutes in the past (then carry on) = 
      save (n) captures timed (m) minutes in the past (then carry on)

    save (n) captures timed (m) minutes in the past (then carry on) = 
      for (i = 0, i < n, i = i + 1)
        save a capture timed (m) minutes in the past (then carry on)

    spread captures over five minutes (then carry on) = 
      then carry on when all are saved = _.after(38, then carry on)

      save (3)  captures timed (5) minutes in the past (then carry on when all are saved)
      save (1)  capture  timed (4) minutes in the past (then carry on when all are saved)
      save (25) captures timed (3) minutes in the past (then carry on when all are saved)
      save (0)  captures timed (2) minutes in the past (then carry on when all are saved)
      save (9)  captures timed (1) minutes in the past (then carry on when all are saved)

    test start time = null

    round (time) to nearest second =
      time - (time % 1000)

    (n) minutes ago to nearest second =
      round (test start time - (n * 1000)) to nearest second

    before each @(ready)
      test start time = new (Date).get time()
      spread captures over five minutes
        ready()

    it "returns a JSON summary of requests over the specified period" @(done)
      request "http://127.0.0.1:9586/requests/summary?over=10&now=#(test start time)" @(err, res, body)
        summary = JSON.parse(body)

        _.keys(summary).length.should.equal(4)

        summary.((5) minutes ago to nearest second).requests.should.equal (3)
        summary.((4) minutes ago to nearest second).requests.should.equal (1)
        summary.((3) minutes ago to nearest second).requests.should.equal (25)
        summary.((1) minutes ago to nearest second).requests.should.equal (9)

        done()
