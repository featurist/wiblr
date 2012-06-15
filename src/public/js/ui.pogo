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

ko.binding handlers.radio click = {
  init (element, value accessor) =
    console.log 'init'
    cycle = ['stuff', 'boats']
    $(element).find '.btn'.click =>
      value = $(self).val ()
      (value accessor ()) (value)

  update (element, value accessor) =
    value = ko.utils.unwrap observable (value accessor ())
    $(element).find ".btn[value=#(value)]".add class 'active'
}

Page = class {
  
  constructor() =
    self.connection status = ko.observable('connecting')
    self.requests = ko.observable array ()
    self.selected request = ko.observable ()

    self.layout = ko.observable ('exchange-list-layout')

    self.body class = ko.computed
      self.connection status () + ' ' + self.layout ()

    $("#load").click
      self.reload historical data()
      
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
    
    $.get("/requests/summary?over=#(self.scale)").done @(captures)
      self.requests([])
      for each @(capture) in (captures)
        self.requests.push (new (Request (self, capture)))

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
    self.content type (fields.content type)
    self.status (fields.status)
    self.response headers (fields.response headers)
   
  make observable(fields) =
    self.uuid              = fields.uuid
    self.time              = fields.time
    self.method            = fields.method
    self.host              = fields.host
    self.path              = fields.path
    self.request headers   = fields.request headers
    self.content type      = ko.observable(fields.content type)
    self.status            = ko.observable(fields.status)
    self.response headers  = ko.observable(fields.response headers)
    
    self.selected = ko.observable(false)
    
    self.sorted request headers = ko.computed
      sorted pairs in (self.request headers)
      
    self.sorted response headers = ko.computed
      sorted pairs in (self.response headers())
    
    self.trimmed path = ko.computed
      trim middle of (self.path || "", 50)
    
    self.simplified content type = ko.computed
      if (self.content type())
        self.content type().split ";".0

    self.kind = ko.computed
      kind = "unknown"
      if (!self.status())
        kind = "pending"

      if (self.content type())
        for @(type) in (content types)
          if (self.content type().match(content types.(type)))
            kind = type

      kind
    
    self.pretty = ko.observable (false)
    
    self.response url = ko.computed
      '/requests/' + self.uuid + '/' + if (self.pretty ())
        'pretty'
      else
        'html'
        
  select() =
    self.page.deselect request ()
    self.page.selected request (self)
    self.selected (true)
}

$
  window.capturesReceived = 0
  window.the page = new (Page ())
  ko.apply bindings (window.the page)
  
  $'.btn-group'.button()

  socket = io.connect()

  socket.on 'connect' 
    window.the page.connected()
    
  socket.on 'disconnect'
    window.the page.disconnected()

  socket.on 'capture' @(request)
    window.capturesReceived = window.capturesReceived + 1
    window.the page.add request (request)

