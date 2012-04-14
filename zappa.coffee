httpProxy = require('http-proxy')
require('zappa') ->
  @enable 'default layout', 'serve jquery',
    'serve sammy', 'minify'
    
  @use 'bodyParser', 'methodOverride', @app.router, 'static'

  @get '/': ->
    @render 'index'
    
  io = @io
  
  @app.use((req, res, next) ->
    if req.url == '/'
      next()
      return
      
    req.url = req.url.replace(/^\/http/,'http')
    io.sockets.emit('request', {time: new Date(), url: req.url, method: req.method})
    
    next()
  )
  
  @on connection: ->
    @emit welcome: {time: new Date()}
  
  @shared '/shared.js': ->
    root = window ? global
    root.sum = (x, y) -> x + y

  @client '/index.js': ->
    @connect()

    @on welcome: ->
      $('#welcome').append "<h2>Listening: #{@data.time}</h2>"
    
    @on request: ->
      $('table#requests tbody').append($("<tr><td>#{@data.method}</td><td>#{@data.url}</td><td>#{@data.time}</td></tr>"))

  @view index: ->
    @title = 'wiblr!'
    @scripts = ['/socket.io/socket.io', '/zappa/jquery',
      '/zappa/sammy', '/zappa/zappa', '/shared', '/index']

    h1 @title
    h3 id: 'welcome'
    table id: 'requests', ->
      thead ->
        tr ->
          th "Method"
          th "Url"
          th "Time"
      tbody ->
        
    style "th,td {padding:0.1em 0.5em;text-align:left}"
    