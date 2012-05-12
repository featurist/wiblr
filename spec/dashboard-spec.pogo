dashboard = require "../src/dashboard"
model = require "../src/model"
express = require "express"
request = require "request"

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