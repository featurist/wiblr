http = require 'http'

http.create server @(req, res)
  headers = {}
  headers.'content-type' = "text/plain"
  res.write head (200, headers) 
  res.end "Hello World\n"
.listen 1337 "127.0.0.1"

console.log 'Server running at http://127.0.0.1:1337/'