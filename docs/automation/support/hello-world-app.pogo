http = require 'http'

http.create server @(req, res)
  res.write head 200
  res.end "Hello World\n"
.listen 1337 "127.0.0.1"

console.log 'Server running at http://127.0.0.1:1337/'