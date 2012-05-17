express = require "express"
request = require "request"
Browser = require "zombie"
model = require "../src/model"

describe "ui"
  
  browser = new (Browser)
  
  mount stub socket io (app) =
    app.get "/socket.io/socket.io.js" @(req, res)
      res.send "window.io = { connect: { on: function() {} } };"
    
  host ui server (listening) =
    app = express.create server()
    app.use (express.static (__dirname + '/../src/public'))
    mount stub socket io (app)
    
    app.listen (7532)
    app.on "listening" (listening)
  
  visit app (done) =
    browser.visit "http://127.0.0.1:7532"
      done()
  
  open request (added) =
    capture = new (model.Capture)
    capture.method = 'GET'
    capture.host = '1.2.3.4'
    capture.path = 'foo/bar'
    capture.time = '2012-01-01T01:02:03'
    capture.request headers = { a  = 'x', b = 'y' }
    capture.save
      request = JSON.stringify(capture.wire object())
      browser.evaluate "thePage.addRequest(#(request));"
      added()
  
  complete request (capture, added) =
    capture.status = 200
    capture.content type = 'text/plain; charset=utf-8'
    capture.response headers = { c = 's', d = 't' }
    capture.save
      request = JSON.stringify(capture.wire object())
      browser.evaluate "thePage.addRequest(#(request));"
      added()

  capture = null

  before @(ready)
    host ui server
      visit app
        open request
          ready()
          
  describe "an open request"
    
    it "renders the request details"
      browser.text ".method".should.equal "GET"
      browser.text ".host".should.equal "1.2.3.4"
      browser.text ".path".should.equal "foo/bar"
      browser.text ".time".should.equal "01:02:03"
      
      browser.text ".status".should.equal ""
      browser.text ".content-type".should.equal ""
      
    describe "a complete request"
    
      before @(ready)
        complete request(capture)
          ready()
    
      it "updates the row with the response details"
        browser.text ".method".should.equal "GET"
        browser.text ".host".should.equal "1.2.3.4"
        browser.text ".path".should.equal "foo/bar"
        browser.text ".time".should.equal "01:02:03"
    
        browser.text ".status".should.equal "200"
        browser.text ".content-type".should.equal "text/plain"
  
      describe "clicking a row"
        before
          browser.evaluate '$(''#requests tr:first'').click();'
    
        it "renders detailed request information"
          browser.text '#selected_request .method'.should.equal 'GET'
          browser.text '#selected_request .status'.should.equal '200'
          browser.text '#selected_request .host'.should.equal '1.2.3.4'
          browser.text '#selected_request .path'.should.equal 'foo/bar'
          browser.text '#selected_request .content-type'.should.equal 'text/plain'
          browser.text '#selected_request .time'.should.equal '2012-01-01T01:02:03.000Z'

        it "renders request headers"
          browser.text '#request_headers .name:first'.should.equal 'a'
          browser.text '#request_headers .value:first'.should.equal 'x'
      
        it "renders response headers"
          browser.text '#response_headers .name:first'.should.equal 'c'
          browser.text '#response_headers .value:first'.should.equal 's'
          