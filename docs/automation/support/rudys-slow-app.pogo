http = require 'http'

http.create server @(req, res)
  headers = {}
  headers.'content-type' = "text/plain"

  set
    res.write head (200, headers) 
    res.end "Hello World\n"
  timeout (500)
.listen 5100 "127.0.0.1"

console.log 'Server running at http://127.0.0.1:5100/'