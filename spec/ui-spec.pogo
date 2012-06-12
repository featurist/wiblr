express = require "express"
request = require "request"
Browser = require "zombie"
model = require "../src/model"
dashboard = require '../src/dashboard'

describe "ui"

  app = null
  browser = null
  io = null

  host ui server (listening) =
    app = require '../src/app'.create app ()
    io = require 'socket.io'.listen (app, {log = false})
    
    app.listen (7532)
    app.on "listening" (listening)

  visit app (done) =
    browser.visit ("http://127.0.0.1:7532") @(errors, browser, status)
      if (status != 200)
        console.log("Status: #(status)")
      
      if (errors && (errors != []))
        console.log(errors)
        
      io.on 'connection'
        done()

  add request (added, capture properties) =
    open request (added, capture properties)
  
  update (capture) with (capture properties) =
    for @(property) in (capture properties)
      if (capture properties.has own property (property))
        capture.(property) = capture properties.(property)
    
  save and emit (capture) then (carry on) =
    capture.save
      io.sockets.emit 'capture' (capture.wire object())
      set timeout
        carry on()
      100

  open request (added, capture properties) =
    capture = new (model.Capture)
    capture.method = 'GET'
    capture.host = '1.2.3.4'
    capture.path = 'foo/bar'
    capture.time = '2012-01-01T01:02:03'
    capture.request headers = { a  = 'x', b = 'y' }
    
    update (capture) with (capture properties)
    save and emit (capture) then (added)

  complete request (capture, added, capture properties) =
    capture.status = 200
    capture.content type = 'text/plain; charset=utf-8'
    capture.response headers = { c = 's', d = 't' }

    update (capture) with (capture properties)
    save and emit (capture) then (added)

  capture = null
  
  when (browser) is ready (do this) then (carry on) =
    browser.wait
      try
        do this ()
        carry on ()
      catch @(ex)
        carry on (ex)

  before each @(ready)  
    host ui server
      browser = new (Browser)
      browser.on("error") @(error)
        console.error(error)
        
      ready()

  after each()
    if (app)
      io.server.close()
        app.close()

  css (selector) should exist =
    (browser.query(selector) == undefined).should.equal(false)

  css (selector) should not exist =
    (browser.query(selector) == undefined).should.equal(true)

  describe "not connected"

    before each @(ready)
      visit app (ready)

    it "shows connecting status"
      //TODO: What is the right way to do this assertion? Cannot get .exists() to work.
      css ('body.connected') should not exist
      css ('body.connecting') should exist

  describe "disconnected"

    before each @(ready)
      visit app (ready)

    it "shows connecting status"
      css ('body.connected') should not exist
      css ('body.connecting') should exist

  describe "connected"

    before each @(ready)
      visit app
        set timeout (ready,100)

    it "shows connected status"
      css ('body.connected') should exist
      css ('body.connecting') should not exist

    describe "an open request"

      before each @(ready)
        open request (ready)

      it "renders the request details"
        browser.text ".method".should.equal "GET"
        browser.text ".host".should.equal "1.2.3.4"
        browser.text ".path".should.equal "foo/bar"
        browser.text ".time".should.equal "2012-01-01T01:02:03.000Z"

        browser.text ".status".should.equal ""
        browser.text ".content-type".should.equal ""

      describe "a complete request"

        before each @(ready)
          complete request(capture,ready)

        it "updates the row with the response details"
          browser.text ".method".should.equal "GET"
          browser.text ".host".should.equal "1.2.3.4"
          browser.text ".path".should.equal "foo/bar"
          browser.text ".time".should.equal "2012-01-01T01:02:03.000Z"

          browser.text ".status".should.equal "200"
          browser.text ".content-type".should.equal "text/plain"

        describe "clicking a row"
          before each
            browser.evaluate '$(''#requests tr'').click();'

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

    describe 'examining the response body'
      escape html (html) =
        html.replace r/</g '&lt;'.replace r/>/g '&gt;'

      select latest request() =
        browser.evaluate "$('#requests tr').eq(0).click();"

      response body () =
        browser.query '#response-body'.contentWindow.document.body.innerHTML

      it 'renders response body' @(finished)
        expected body = "<html><head></head><body><h1>Hi, this is HTML that wont be pretty</h1></body></html>"
        escaped expected body = escape html (expected body)

        add request (
          response body: expected body
          content type: 'text/html'
          path: '/ugly.html'
        ) @{
          select latest request()
          when (browser) is ready
            actual body = response body ()
            actual body.should.include (escaped expected body)
          then (finished)
        }

      it 'renders pretty response body when pretty checkbox is checked' @(finished) =>
        raw response body = "<html><head></head><body><h1>Hi, this is HTML that will be pretty</h1></body></html>" 

        expected body = "<html>
                           <head></head>
                           <body>
                             <h1>Hi, this is HTML that will be pretty</h1>
                           </body>
                         </html>"

        escaped expected body = escape html (expected body)

        add request (
          response body: raw response body
          content type: 'text/html'
          path: '/pretty.html'
        ) @{
          select latest request()
          browser.check '.pretty-response-body'
          when (browser) is ready
            actual body = response body ()
            actual body.should.include (escaped expected body)
          then (finished)
        }