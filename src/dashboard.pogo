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

  app.get "/exchanges/summary?" @(req, res)
    now = req.query.now || new(Date()).get time()
    from = get date to nearest second at (req.query.over) mins before (now)

    summary = {}

    model.Capture.since (from) @(err, captures)
      res.content type ('application/json')
      res.send (captures)

  app.get "/exchanges/:uuid/responsebody" @(req, res)
    find exchange (req.params.uuid) @(err, exchange)
      if (err)
        res.send (err.to string())
      else
        res.send (exchange.response body, 'content-type': exchange.response headers.'content-type')

  app.get "/exchanges/:uuid/requestbody" @(req, res)
    find exchange (req.params.uuid) @(err, exchange)
      if (err)
        res.send (err.to string())
      else
        res.send (exchange.request body, 'content-type': exchange.request headers.'content-type')

  app.get "/exchanges/:uuid/requestbody/html" @(req, res)
    render request body (req, res)

  app.get "/exchanges/:uuid/requestbody/pretty" @(req, res)
    render request body (req, res, pretty: true)

  app.get "/exchanges/:uuid/responsebody/html" @(req, res)
    render response body (req, res)

  app.get "/exchanges/:uuid/responsebody/pretty" @(req, res)
    render response body (req, res, pretty: true)

  find exchange (uuid, done) =
    model.Capture.find one { uuid = uuid } (done)
  
  render response body (req, res, pretty: false) =
    find exchange (req.params.uuid) @(err, exchange)
      if (exchange.has response body())
        res.header 'cache-control' 'max-age=31536000 private'
        if (exchange.can render response body as text ())
          render text body (exchange.read response body (), exchange.response headers.'content-type', res, pretty)
        else
          render image body (res, exchange)
      else
        render missing body (res)
  
  render request body (req, res, pretty: false) =
    find exchange (req.params.uuid) @(err, exchange)
      res.header 'cache-control' 'max-age=31536000 private'
      if (exchange.can render request body as text ())
        render text body (exchange.read request body (), exchange.request headers.'content-type', res, pretty)
      else
        render image body (res, exchange)

  render text body (body, content type, res, pretty) =
    if (pretty)
      body = prettify (body, content type: content type)

    res.render ('responseBody.html', body: body, pretty: pretty, ugly: !pretty, layout: false)

  render image body (res, exchange) =
    res.send ("<img src='/exchanges/#(exchange.uuid)/responsebody' />", 'content-type': 'text/html')

  render missing body (res) =
    res.send ('<html><body><p>[no response]</p></body></html>', 'content-type': 'text/html')
