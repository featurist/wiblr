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
      capture.response body = new (Buffer "happy days")
      capture.content type = "text/plain"
      capture.save
        request "http://127.0.0.1:9586/requests/#(capture.uuid)" @(err, res, body)
          res.headers.'content-type'.should.equal 'text/plain'
          body.should.equal("happy days")
          done()

  describe '/requests/:id/pretty, when the content is html'
    it 'renders a textarea, with the html indented' @(done)
      capture = new (model.Capture)
      capture.response body = new (Buffer "<html><body><h1>hi</h1></body></html>")
      capture.content type = "text/html"
      capture.save
        request "http://127.0.0.1:9586/requests/#(capture.uuid)/html" @(err, res, body)
          res.headers.'content-type'.should.equal 'text/html; charset=utf-8'
          body.should.include "<html>
                                 <body>
                                   <h1>hi</h1>
                                 </body>
                               </html>"
          done()

  describe "/requests/:id/html, when the content is text"

    it "renders a textarea" @(done)
    
      capture = new (model.Capture)
      capture.response body = new (Buffer "<html><body><h1>hi</h1></body></html>")
      capture.content type = "text/html"
      capture.save
        request "http://127.0.0.1:9586/requests/#(capture.uuid)/html" @(err, res, body)
          res.headers.'content-type'.should.equal 'text/html; charset=utf-8'
          body.should.include("<textarea")
          body.should.include "<html><body><h1>hi</h1></body></html>"
          done()

  describe "/requests/:id/html, when the content is an image"

    it "renders an img" @(done)

      capture = new (model.Capture)
      capture.response body = new (Buffer (0))
      capture.content type = "image/png"
      capture.save
        request "http://127.0.0.1:9586/requests/#(capture.uuid)/html" @(err, res, body)
          res.headers.'content-type'.should.equal 'text/html; charset=utf-8'
          body.should.include("<img")
          done()