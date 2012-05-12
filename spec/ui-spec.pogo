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
  
  add some requests (added) =
    capture = new (model.Capture)
    capture.method = 'GET'
    capture.status = 200
    capture.host = '1.2.3.4'
    capture.path = 'foo/bar'
    capture.content type = 'text/plain'
    capture.time = '2012-01-01T01:02:03'
    capture.save
      browser.visit "http://127.0.0.1:7532"
        request = JSON.stringify(capture.wire object())
        browser.evaluate "thePage.addRequest(#(request));"
        added()

  before @(ready)
    host ui server
      add some requests
        ready()
    
  it "renders the request details"
    browser.text ".method".should.equal "GET"
    browser.text ".status".should.equal "200"
    browser.text ".host".should.equal "1.2.3.4"
    browser.text ".path".should.equal "foo/bar"
    browser.text ".content-type".should.equal "text/plain"
    browser.text ".time".should.equal "01:02:03"
  
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
      
