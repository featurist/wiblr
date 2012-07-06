express = require 'express'
connect = require 'connect'

after (milliseconds, action) =
  set timeout (action, milliseconds)

(n)ms = n

exports.create teapot app () =
  teapot app = express.create server ()
  
  pour tea (req, res) =
    after (10ms)
      res.header 'content-type' 'earl/grey'
      res.send "I'm a teapot\n" 418
  
  pour gzipped tea (req, res) =
    after (10ms)
      res.header 'content-type' 'earl/grey'
      res.gzip = true
      res.send "I'm a teapot\n" 418

  teapot app.use (connect.compress (filter (req, res): res.gzip))
  teapot app.get ('/teapot', pour tea)
  teapot app.post ('/teapot', pour tea)

  teapot app.get ('/teapot_gzip', pour gzipped tea)
  teapot app.post ('/teapot_gzip', pour gzipped tea)

  teapot app