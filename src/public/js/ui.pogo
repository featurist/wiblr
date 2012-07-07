trim middle of (string, length) =
  if (string.length > length)
    start = string.substring 0 (length / 2)
    end = string.substring (string.length - (length / 2), string.length)
    "#(start) ... #(end)"
  else
    string

sorted pairs in (object) =
  pairs = _.map (object) @(value, name)
    { name = name, value = value }

  _.sort by (pairs) @(pair)
    pair.name

ko.binding handlers.time = {
  update (element, value accessor) =
    value = ko.utils.unwrap observable (value accessor())
    pattern = 'HH:mm:ss'
    $(element).text(moment(value).format(pattern))
}

ko.binding handlers.group toggle = {
  init (element, value accessor) =
    $(element).find '.btn'.click =>
      value = $(self).val ()
      (value accessor ()) (value)

  update (element, value accessor) =
    value = ko.utils.unwrap observable (value accessor ())
    $(element).find ".btn[value!=#(value)]".remove class 'active'
    $(element).find ".btn[value=#(value)]".add class 'active'
}

Page = class {
  
  constructor() =
    self.connection status = ko.observable('connecting')
    self.requests = ko.observable array ()
    self.selected request = ko.observable ()
    self.layout = ko.observable ('split')
    self.pretty = ko.observable (false)

    $("#load").click
      self.reload historical data()

    $(".layout.button").click @(e)
      self.change_layout(e)

  change_layout(e) =
    self.layout($(e.currentTarget).attr('data-layout'))
    false

  connected () =
    self.connection status("connected")

  disconnected () =
    self.connection status("connecting")

  round (time) to nearest second =
    time - (time % 1000)

  reload historical data() =
    self.scale = $("#scale").val()
    max x = self.round (new(Date()).get time()) to nearest second
    min x = max x - (self.scale * (60 * 1000))

    $.get("/exchanges/summary?over=#(self.scale)").done @(exchanges)
      self.requests([])
      for each @(exchange) in (exchanges)
        self.requests.push (new (Request (self, exchange)))

  add request (data) =

    open request = _.find(self.requests()) @(request)
      request.uuid == data.uuid

    if (open request)
      open request.update(data)
    else
      self.requests.unshift (new (Request (self, data)))

  deselect request () =
    r = self.selected request()
    if (r) @{ r.selected (false) }

}

content types = {
  txt = r/text\/plain/
  jpg = r/jpe?g/
  png = r/png/
  gif = r/gif/
  html  = r/html/
  css = r/css/
  js = r/javascript/
  json = r/json/
}

Request = $class {

  constructor (page, fields) =
    self.page = page
    self.make observable(fields)

  update(fields) =
    self.content length (fields.content length)
    self.status (fields.status)
    self.response headers (fields.response headers)

  make observable(fields) =
    self.uuid              = fields.uuid
    self.time              = fields.time
    self.method            = fields.method
    self.protocol          = fields.protocol 
    self.host              = fields.host
    self.path              = fields.path
    self.url               = fields.url
    self.request headers   = fields.request headers
    
    self.content length    = ko.observable(fields.content length)
    self.status            = ko.observable(fields.status)
    self.response headers  = ko.observable(fields.response headers)
    self.scheme = 'http'

    self.selected = ko.observable(false)
    self.over = ko.observable(false)
    self.toggle over() = 
      self.over(!self.over())

    self.sorted request headers = ko.computed
      sorted pairs in (self.request headers)

    self.sorted response headers = ko.computed
      sorted pairs in (self.response headers())

    self.trimmed path = ko.computed
      trim middle of (self.path || "", 50)

    self.response content type = ko.computed
      headers = self.response headers ()

      if (headers)
        headers.'content-type'

    self.simplified response content type = ko.computed
      if (self.response content type())
        self.response content type().split ";".0

    self.status classes =
      'status-' + (self.status() + '').[0] + 'xx status-' + self.status()

    self.kind = ko.computed
      kind = "unknown"
      if (!self.status())
        kind = "pending"

      if (self.response content type())
        for @(type) in (content types)
          if (self.response content type().match(content types.(type)))
            kind = type

      kind

    self.colspan = ko.computed
      if (self.over())
        5
      else
        1

    self.response url = ko.computed
      '/exchanges/' + self.uuid + '/responsebody/' + if (self.page.pretty ())
        'pretty'
      else
        'html'

    self.request href = ko.computed
      if (r/get/i.test (self.method))
          self.url

  select() =
    was selected = self.selected()
    self.page.deselect request ()
    self.page.selected request (self)
    self.selected (true)

    if (self.recently selected)
      clear timeout (self.click timeout)
      action() =
        self.double click(was selected)
    else
      action() =
        self.single click(was selected)

    self.recently selected = true
    self.click timeout = set timeout
      self.recently selected = false
      action()
    250

  single click(was selected) =
    if ((self.page.layout() == 'split') && (was selected))
      self.page.layout('list')
      return

    if ((self.page.layout() == 'detail') && (was selected))
      self.page.layout('split')
      return

    if (self.page.layout() == 'list')
      self.page.layout('split')
      return


  double click(was selected) =
    if ((self.page.layout() == 'detail') && (was selected))
      self.page.layout('split')
    else
      self.page.layout('detail')

}

$
  $('html').removeClass('preload')
  window.exchangesReceived = 0
  window.the page = new (Page ())
  ko.apply bindings (window.the page)

  $'.btn-group'.button()
  
  socket = io.connect()

  socket.on 'connect'
    window.the page.connected()

  socket.on 'disconnect'
    window.the page.disconnected()

  socket.on 'exchange' @(request)
    window.exchangesReceived = window.exchangesReceived + 1
    window.the page.add request (request)

