model = require './model'
prettify = require './pretty'.prettify

exports.mount (app) =

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

    model.Capture.since (from) @(err, captures)
      res.content type ('application/json')
      res.send (captures)

  app.get "/requests/:uuid" @(req, res)
    model.Capture.find one { uuid = req.params.uuid } @(err, capture)
      if (err)
        res.send (err.to string())
      else
        res.send (capture.response body, 'content-type': capture.content type)

  app.get "/requests/:uuid/html" @(req, res)
    render body (req, res)

  app.get "/requests/:uuid/pretty" @(req, res)
    render body (req, res, pretty: true)
  
  render body (req, res, pretty: false) =
    model.Capture.find one { uuid = req.params.uuid } @(err, capture)
      if (capture.has response body())
        res.header 'cache-control' 'max-age=31536000 private'
        if (capture.should render as text())
          render text body (res, capture, pretty)
        else
          render image body (res, capture)
      else
        render missing body (res)

  render text body (res, capture, pretty) =
    body = capture.read response body()
    if (pretty)
      body = prettify (body, content type: capture.content type)

    res.render ('responseBody.html', body: body, pretty: pretty, ugly: !pretty, layout: false)

  render image body (res, capture) =
    res.send ("<img src='/requests/#(capture.uuid)' />", 'content-type': 'text/html')

  render missing body (res) =
    res.send ('<html><body><p>[no response]</p></body></html>', 'content-type': 'text/html')
