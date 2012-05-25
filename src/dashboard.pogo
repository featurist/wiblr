model = require './model'
prettify = require './pretty'.prettify

exports.mount (app) =

  decode base64 as utf8 (base64) =
    buffer = new (Buffer (base64, 'base64'))
    buffer.to string('utf-8')

  app.get "/requests/:uuid" @(req, res)
    model.Capture.find one { uuid = req.params.uuid } @(err, capture)
      res.send (capture.response body, 'content-type': capture.content type)

  app.get "/requests/:uuid/html" @(req, res)
    render body (req, res)

  app.get "/requests/:uuid/pretty" @(req, res)
    render body (req, res, pretty: true)

  render body (req, res, pretty: false) =
    model.Capture.find one { uuid = req.params.uuid } @(err, capture)
      if (capture.response body == nil)
        res.end ('', 'content-type': 'text/plain')
      else
        reg = r/(text|css|javascript|json|xml)/
        if (capture.content type.match (reg))
          body = decode base64 as utf8 (capture.response body)
      
          pretty body = if (pretty)
            prettify (body, content type: capture.content type)
          else
            body
        
          res.render 'responseBody.html' (pretty body: pretty body, layout: false)
        else
          res.send "<img src='/requests/#(capture.uuid)' />"
