express = require "express"
request = require "request"
Browser = require "zombie"
model = require "../src/model"
dashboard = require '../src/dashboard'

describe "ui"
  
  browser = new (Browser)
  
  mount stub socket io (app) =
    app.get "/socket.io/socket.io.js" @(req, res)
      res.send "window.io = { connect: { on: function() {} } };"
    
  host ui server (listening) =
    app = express.create server()
    app.use (express.static (__dirname + '/../src/public'))
    mount stub socket io (app)
    dashboard.mount (app)
    app.listen (7532)
    app.on "listening" (listening)
  
  visit app (done) =
    browser.visit "http://127.0.0.1:7532"
      done()
  
  add request (added, capture properties) =
    capture = new (model.Capture)

    capture.method = 'GET'
    capture.status = 200
    capture.host = '1.2.3.4'
    capture.path = 'foo/bar'
    capture.content type = 'text/plain; charset=utf-8'
    capture.time = '2012-01-01T01:02:03'
    capture.response body = ''
    capture.request body = ''
    capture.request headers = { a = 'x', b = 'y' }
    capture.response headers = { c = 's', d = 't' }
    
    for @(property) in (capture properties)
      if (capture properties.has own property (property))
        capture.(property) = capture properties.(property)
    
    capture.save
      request = JSON.stringify(capture.wire object())
      browser.evaluate "thePage.addRequest(#(request));"
      added()

  before @(ready)
    host ui server
      visit app
        add request
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
      select 1st request
    
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
    
    escape html (html) =
      html.replace r/</g '&lt;'.replace r/>/g '&gt;'
    
    select (n)th request =
      browser.evaluate "$('#requests tr:nth-child(#(n))').click();"
    
    select st request = select nd request = select th request
    
    response body () =
      browser.query '#response-body'.contentWindow.document.body.innerHTML
    
    it 'renders response body' @(finished)
      expected body = "<html><head></head><body><h1>Hi, this is HTML</h1></body></html>"
      escaped expected body = escape html (expected body)
      
      add request (
        response body: expected body
        content type: 'text/html'
        path: '/some.html'
      ) @{
        select 2nd request
        browser.wait
          actual body = response body ()
          actual body.should.include (escaped expected body)
          finished ()
      }

    it 'renders pretty response body when pretty checkbox is checked' @(finished) =>
      raw response body = "<html><head></head><body><h1>Hi, this is HTML</h1></body></html>"

      expected body = "<html>
                         <head></head>
                         <body>
                           <h1>Hi, this is HTML</h1>
                         </body>
                       </html>"
                       
      escaped expected body = escape html (expected body)
      
      add request (
        response body: raw response body
        content type: 'text/html'
        path: '/some.html'
      ) @{
        select 2nd request
        browser.check '.pretty-response-body'
        times called = 0
        browser.wait
          actual body = response body ()
          actual body.should.include (escaped expected body)
          finished ()
      }
