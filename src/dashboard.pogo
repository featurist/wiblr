model = require './model'

exports.mount (app) =

  decode base64 as utf8 (base64) =
    buffer = new (Buffer (base64, 'base64'))
    buffer.to string('utf-8')

  round (time) to nearest second =
    time - (time % 1000)

  get date to nearest second at (n) mins before (time) =
    date = new(Date())
    date.set time(time)

    n mins ago = date.get time() - (n * 1000)
    time = round (n mins ago) to nearest second

    date.set time(time)

  app.get "/requests/summary?" @(req, res)
    now = req.query.now || new(Date()).get time()
    from = get date to nearest second at (req.query.over) mins before (now)

    summary = {}

    model.Capture.find().where('time').gte(from).run  @(err, captures)
      for each @(capture) in (captures)

        time = round (new (Date(capture.time)).get time()) to nearest second

        if (!summary.(time))
          summary.(time) = {requests 1}
        else
          summary.(time).requests = summary.(time).requests + 1

      res.content type ('application/json')
      res.send (JSON.stringify(summary))

  app.get "/requests/:uuid" @(req, res)
    model.Capture.find one { uuid = req.params.uuid } @(err, capture)
      res.content type (capture.content type)
      res.send (capture.response body)

  app.get "/requests/:uuid/html" @(req, res)
    res.content type ("text/html")
    model.Capture.find one { uuid = req.params.uuid } @(err, capture)
      reg = r/(text|css|javascript|json|xml)/
      if (capture.content type.match (reg))
        res.send "
          <html>
            <body style='margin:0; padding: 0'>
              <textarea style='width: 100%; height:100%;border:0'>#(decode base64 as utf8 (capture.response body))</textarea>
            </body>
          </html>"
      else
        res.send "<img src='/requests/#(capture.uuid)' />"
