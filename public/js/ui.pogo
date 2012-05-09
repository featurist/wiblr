$
  Page = $class {
    constructor () = @{
      self.requests = ko.observable array ()
    }
  
    add request (request) =
      self.requests.push (request)
  }

  window.the page = new (Page ())

  ko.apply bindings (window.the page)

  socket = io.connect()
  socket.on 'capture' @(request)
    window.the page.add request (request)
