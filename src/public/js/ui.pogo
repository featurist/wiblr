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

Page = class {
  
  constructor () =
    self.requests = ko.observable array ()
    self.selected request = ko.observable ()

  add request (data) =
    uuids = self.requests().map @(request)
      request.uuid
      
    console.log("looking for: " + data.uuid + " in " + uuids)
    open request = _.find(self.requests()) @(request)
      console.log(request.uuid(),data.uuid)
      request.uuid() == data.uuid
    
    if (open request)
      console.log('found')
      open request.update(data)
    else      
      console.log('not found')
      self.requests.push (new (Request (self, data)))

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

Request = class {
  
  constructor (page, fields) =
    self.page = page
    self.make observable(fields)
  
  update(fields) =
   for @(field) in (fields)
     self.(field)(fields.(field))
   
  make observable(fields) =
    self.uuid              = ko.observable(fields.uuid)
    self.content type      = ko.observable(fields.content type)
    self.time              = ko.observable(fields.time)
    self.method            = ko.observable(fields.method)
    self.host              = ko.observable(fields.host)
    self.path              = ko.observable(fields.path)
    self.status            = ko.observable(fields.status)
    self.request headers   = ko.observable(fields.request headers)
    self.response headers  = ko.observable(fields.response headers)
    
    self.selected = ko.observable(false)
    
    self.sorted request headers = ko.computed
      sorted pairs in (self.request headers())
      
    self.sorted response headers = ko.computed
      sorted pairs in (self.response headers())
    
    self.trimmed path = ko.computed
      trim middle of (self.path(), 50)
    
    self.simplified content type = ko.computed
      if (self.content type())
        self.content type().split ";".0
      
    self.kind = ko.computed
      if (!self.content type())
        kind = ""
      else 
        kind = "unknown"
        for @(type) in (content types)
          if (self.content type().match(content types.(type)))
            kind = type
        
      kind
      
        
  select() =
    self.page.deselect request ()
    self.page.selected request (self)
    self.selected (true)

}

$ 
  window.the page = new (Page ())
  ko.apply bindings (window.the page)
  socket = io.connect()
  socket.on 'capture' @(request)
    window.the page.add request (request)
