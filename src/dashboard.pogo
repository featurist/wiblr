model = require './model'

exports.mount (app) =

  decode base64 as utf8 (base64) =
    buffer = new (Buffer (base64, 'base64'))
    buffer.to string('utf-8')

  app.get "/requests/:uuid" @(req, res)
    model.Capture.find one { uuid = req.params.uuid } @(err, capture)
      res.content type (capture.content type)
      res.send (capture.response body)

  app.get "/requests/:uuid/html" @(req, res)
    res.content type ("text/html")
    model.Capture.find one { uuid = req.params.uuid } @(err, capture)
      reg = new (RegExp "(text|css|javascript|json|xml)")
      if (capture.content type.match (reg))
        res.send "
          <html>
            <body style='margin:0; padding: 0'>
              <textarea style='width: 100%; height:100%'>#(decode base64 as utf8 (capture.response body))</textarea>
            </body>
          </html>"
      else
        res.send "<img src='/requests/#(capture.uuid)' />"