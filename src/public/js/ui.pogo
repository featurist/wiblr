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
    pattern = 'hh:mm:ss'
    $(element).text(moment(value).format(pattern))
}

Page = $class {
  
  constructor () =
    self.requests = ko.observable array ()
    self.selected request = ko.observable ()

  add request (data) =
    self.requests.push (new (Request (self, data)))
  
  deselect request () =
    r = self.selected request()
    if (r) @{ r.selected (false) }
    
}

content types = {
  image = new (RegExp "image")
  code  = new (RegExp "(html|javascript|css|xml)")
  text  = new (RegExp "text/plain")
}

Request = $class {
  
  constructor (page, fields) =
    self.page = page
    self.response body = ko.observable ()
    for @(field) in (fields)
      self.(field) = fields.(field)
    
    self.selected = ko.observable(false)
    
    self.sorted request headers = ko.computed
      sorted pairs in (self.request headers)
      
    self.sorted response headers = ko.computed
      sorted pairs in (self.response headers)
    
    self.trimmed path = ko.computed
      trim middle of (self.path, 50)
      
    self.kind = ko.computed
      kind = "unknown"
      for @(type) in (content types)
        if (self.content type.match(content types.(type)))
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
