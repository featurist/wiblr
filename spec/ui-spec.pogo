express = require "express"
request = require "request"
Browser = require "zombie"

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
    browser.visit "http://127.0.0.1:7532" =>
      browser.evaluate "
        thePage.addRequest({
          method: 'GET',
          status: 200,
          host: '1.2.3.4',
          path: 'foo/bar',
          uuid: 'uuid-1',
          contentType: 'text/plain',
          time: '2012-01-01T01:02:03'
        });"
      added()

  before @(done)
    host ui server
      add some requests
        done()
    
  it "renders the request details"
    browser.text(".method").should.equal("GET")
    browser.text(".status").should.equal("200")
    browser.text(".host").should.equal("1.2.3.4")
    browser.text(".path").should.equal("foo/bar")
    browser.text(".content-type").should.equal("text/plain")
    browser.text(".time").should.equal("01:02:03")

