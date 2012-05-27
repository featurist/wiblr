model = require './model'
prettify = require './pretty'.prettify

exports.mount (app) =

  decode base64 as utf8 (base64) =
    buffer = new (Buffer (base64, 'base64'))
    buffer.to string('utf-8')

  round (time) to nearest second =
    time - (time % 1000)

  get date to nearest second at (n) mins before (time) =
    date = new(Date())
    date.set time(time)

    n mins ago = date.get time() - ((n * 60) * 1000)
    time = round (n mins ago) to nearest second

    date.set time(time)

  app.get "/requests/summary?" @(req, res)
    now = req.query.now || new(Date()).get time()
    from = get date to nearest second at (req.query.over) mins before (now)

    summary = {}

    model.Capture.find().where('time').gte(from).sort('time', -1).run  @(err, captures)
      for each @(capture) in (captures)
        capture.response body = null

      res.content type ('application/json')
      res.send (captures)

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
        
          res.header 'cache-control' 'max-age=31536000 private'
          res.render ('responseBody.html', body: pretty body, pretty: pretty, layout: false)
        else
          res.header 'cache-control' 'max-age=31536000 private'
          res.send ("<img src='/requests/#(capture.uuid)' />", 'content-type': 'text/html')
