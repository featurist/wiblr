express = require "express"
request = require "request"
Browser = require "zombie"

describe "ui"
  before
    app = express.create server()
    app.use (express.static (__dirname + '/../src/public'))
    app.get "/socket.io/socket.io.js" @(req, res)
      res.send "window.io = { connect: { on: function() {} } };"
      
    app.listen (7532)

  it "renders a table of requests" @(done)
    
    browser = new (Browser)
    browser.visit "http://127.0.0.1:7532"
      browser.evaluate "
        window.thePage.addRequest({
          method: 'GET',
          status: 200,
          host: '1.2.3.4',
          path: 'foo/bar',
          uuid: 'uuid-1',
          contentType: 'text/plain',
          time: '2012-01-01'
        });
      "
      browser.text(".method").should.equal("GET")
      
      done()