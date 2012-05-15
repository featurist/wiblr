http = require 'http'

http.create server @(req, res)
  headers = {}
  headers.'content-type' = "text/plain"
  
  time now() =
    date = new (Date)
    date.getTime()
  
  sleep(milliSeconds) =
      startTime = time now()
      while (time now() < (startTime + milliSeconds)) @{}

  sleep(2000)
  
  res.write head (200, headers) 
  res.end "Hello World\n"
.listen 5100 "127.0.0.1"

console.log 'Server running at http://127.0.0.1:5100/'