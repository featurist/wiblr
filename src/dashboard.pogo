model = require './model'

exports.mount (app) =

  decode base64 as utf8 (base64) =
    buffer = new (Buffer (base64, 'base64'))
    buffer.to string('utf-8')

  app.get "/requests/:uuid" @(req, res)
    model.Capture.find one { uuid = req.params.uuid } @(err, capture)
      res.send (capture.response body, 'content-type': capture.content type)

  app.get "/requests/:uuid/html" @(req, res)
    model.Capture.find one { uuid = req.params.uuid } @(err, capture)
      reg = r/(text|css|javascript|json|xml)/
      if (capture.content type.match (reg))
        res.send "
          <html>
            <body style='margin:0; padding: 0'>
              <textarea style='width: 100%; height:100%;border:0'>#(decode base64 as utf8 (capture.response body))</textarea>
            </body>
          </html>" ('content-type': 'text/html')
      else
        res.send "<img src='/requests/#(capture.uuid)' />"