express = require 'express'

app = express.create server ()

hello world (response) =
  response.write head (200, 'content-type': "text/plain") 
  response.end "Hello World\n"

app.get "/slow" @(req, res)
  set
    hello world (res)
  timeout (500)

app.get "/" @(req, res)
  hello world (res)

app.listen 1337 "127.0.0.1"

console.log 'Server running at http://127.0.0.1:1337/'