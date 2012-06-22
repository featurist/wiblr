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

  update (capture) with (capture properties) =
    for @(property) in (capture properties)
      if (capture properties.has own property (property))
        capture.(property) = capture properties.(property)

  save and emit (capture) then (carry on) =
    capture.save
      io.sockets.emit 'capture' (capture.wire object())
      set timeout
        carry on()
      10

  add request (capture properties) then (carry on) =
    capture = new (model.Capture)
    capture.method = 'GET'
    capture.host = '1.2.3.4'
    capture.path = '/foo/bar'
    capture.url = 'http://1.2.3.4/foo/bar'
    capture.time = '2012-01-01T01:02:03'
    capture.request headers = { a  = 'x', b = 'y' }
    
    update (capture) with (capture properties)
    save and emit (capture) then (carry on)

  complete request (capture, added, capture properties) =
    capture.status = 200
    capture.content type = 'text/plain; charset=utf-8'
    capture.response headers = { c = 's', d = 't' }
    capture.append response body (new (Buffer "howdy"))
    capture.append response body (new (Buffer "doody"))

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

  click button (name) and check (assertions) on failure (fail) on success (succeed) =
    browser.press button ("button:contains(#(name))")
      try
        assertions()
        succeed ()
      catch @(ex)
        fail (ex)

  before each @(ready)
    host ui server
      browser = new (Browser)
      browser.on("error") @(error)
        console.error(error)

      ready()

  after each()
    if (app)
      app.close()

  css (selector) should exist =
    (browser.query(selector) == undefined).should.equal(false, "Expected to find CSS selector: #(selector)")

  css (selector) should not exist =
    (browser.query(selector) == undefined).should.equal(true, "Expected NOT to find CSS selector: #(selector)")

  describe 'layout'

    before each @(ready)
      visit app (ready)

    it 'defaults to split layout'
      css 'body.split' should exist
      css 'body.detail, body.list' should not exist

    describe 'changed by user'

      it 'switches layout class on the body' @(done)

        click button ('list') and check
          css 'body.list' should exist
          css 'body.split, body.detail' should not exist
        on failure (done) on success
          click button ('split') and check
            css 'body.split' should exist
            css 'body.detail, body.list' should not exist
          on failure (done) on success
            click button ('detail') and check
              css 'body.detail' should exist
              css 'body.split, body.list' should not exist
            on failure (done) on success (done)

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
        add request ({}) then (ready)

      it "renders the request details"
        browser.text ".method".should.equal "GET"
        browser.text ".host".should.equal "1.2.3.4"
        browser.text '.path .trimmed'.should.equal '/foo/bar'
        browser.text '.path .full'.should.equal 'http://1.2.3.4/foo/bar'
        browser.text ".time".should.equal "2012-01-01T01:02:03.000Z"
        browser.text ".status".should.equal ""
        browser.text ".content-type".should.equal ""

      describe "a complete request"

        before each @(ready)
          complete request(capture,ready)

        it "updates the row with the response details"
          browser.text ".method".should.equal "GET"
          browser.text ".host".should.equal "1.2.3.4"
          browser.text '.path .trimmed'.should.equal '/foo/bar'
          browser.text '.path .full'.should.equal 'http://1.2.3.4/foo/bar'
          browser.text ".time".should.equal "2012-01-01T01:02:03.000Z"
          browser.text ".status".should.equal "200"
          browser.text ".content-type".should.equal "text/plain"

        click the first row() =
          browser.evaluate '$(''#requests tbody tr'').click();'

        describe "clicking a row"

          before each
            click the first row()
            
          it "renders detailed request information"
            browser.text '#selected_request .method'.should.equal 'GET'
            browser.text '#selected_request .status'.should.equal '200'
            browser.text '#selected_request .host'.should.equal '1.2.3.4'
            browser.text '#selected_request .path'.should.equal '/foo/bar'
            browser.text '#selected_request .content-type'.should.equal 'text/plain'
            browser.text '#selected_request .time'.should.equal '2012-01-01T01:02:03.000Z'
            browser.text '#selected_request .content-length'.should.equal '10'

          it "renders request headers"
            browser.text '#request_headers .name:first'.should.equal 'a'
            browser.text '#request_headers .value:first'.should.equal 'x'

          it "renders response headers"
            browser.text '#response_headers .name:first'.should.equal 'c'
            browser.text '#response_headers .value:first'.should.equal 's'

        describe "clicking a row when in list layout"

          before each @(ready)
            browser.press button 'button:contains(list)' @(err)
              click the first row()
              browser.wait
                ready (err)

          it "switches to split layout"
              css 'body.split' should exist
              css 'body.list' should not exist

        describe "clicking a row when in split layout"

          before each @(ready)
            browser.press button ('button:contains(split)', ready)

          it "switches to list layout"
            click the first row()
            browser.wait
              css 'body.list' should exist
              css 'body.split' should not exist

          describe "switching to another row"

            it "stays in split layout" @(done)
              add request ({}) then
                css 'body.split' should exist
                done()

        describe "clicking a row when in detail layout"

          before each @(ready)
            browser.press button ('button:contains(detail)') @(err)
              click the first row()
              browser.wait
                ready(err)

          it "stays in detail layout"
            css 'body.detail' should exist

        describe "double-clicking a row"

          click the first row() =
            browser.evaluate '$(''#requests tbody tr'').click();'

          double click the first row() =
            click the first row()
            click the first row()

          describe "in list layout"

            before each @(ready)
              browser.press button ('button:contains(list)') @(err)
                double click the first row()
                browser.wait
                  ready(err)

            it "switches to detail layout"
              css 'body.detail' should exist
              css 'body.list' should not exist

          describe "in split layout"

            before each @(ready)
              browser.press button ('button:contains(split)') @(err)
                double click the first row()
                browser.wait
                  ready (err)

            it "switches to detail layout"
              css 'body.detail' should exist
              css 'body.split' should not exist

          describe "in detail layout"

            before each @(ready)
              browser.press button ('button:contains(detail)') @(err)
                double click the first row()
                browser.wait
                  ready()

            it "switches to split layout"
              css 'body.split' should exist
              css 'body.list' should not exist



    describe 'examining the response body'
      escape html (html) =
        html.replace r/</g '&lt;'.replace r/>/g '&gt;'

      select latest request() =
        select request at index (0)

      select request at index (index) =
        browser.evaluate "$('#requests tbody tr').eq(#(index)).click();"

      response body () =
        browser.query '#response-body'.contentWindow.document.body.innerHTML

      it 'renders response body' @(finished)
        expected body = "<html><head></head><body><h1>Hi, this is HTML that wont be pretty</h1></body></html>"
        escaped expected body = escape html (expected body)

        request = {
          response body = expected body
          content type = 'text/html'
          path = '/ugly.html'
        }
        add request (request) then
          select latest request()
          when (browser) is ready
            actual body = response body ()
            actual body.should.include (escaped expected body)
          then (finished)

      describe 'when pretty is checked'

        before each @(ready)
          raw response body = "<html><head></head><body><h1>Hi, this is HTML that will be pretty</h1></body></html>"
          request = {
            response body = raw response body
            content type = 'text/html'
            path= '/pretty.html'
          }
          add request (request) then
            select latest request()
            browser.wait
              browser.check '.pretty-response-body'
              ready()

        it 'renders pretty response body' @(finished)

          expected body = "<html>
                             <head></head>
                             <body>
                               <h1>Hi, this is HTML that will be pretty</h1>
                             </body>
                           </html>"

          escaped expected body = escape html (expected body)

          when (browser) is ready
            actual body = response body ()
            actual body.should.include (escaped expected body)
          then (finished)


        it 'stays in pretty view when the next response is loaded' @(finished)

          expected body = "<html>
                             <head></head>
                             <body>
                               <h1>Hi, this is another response HTML that will also be pretty</h1>
                             </body>
                           </html>"

          escaped expected body = escape html (expected body)

          raw response body = "<html><head></head><body><h1>Hi, this is another response HTML that will also be pretty</h1></body></html>"
          request = {
            response body = raw response body
            content type = 'text/html'
            path = '/pretty.html'
          }
          add request (request) then
            select latest request()
            when (browser) is ready
              actual body = response body ()
              actual body.should.include (escaped expected body)
            then (finished)
