proxy = require "../src/proxy"
model = require "../src/model"

request = require 'request'
http = require 'http'
should = require 'should'

describe "proxy"
  
  teapot app = http.create server @(req, res)
    headers = {}
    headers.'content-type' = "earl/grey"
    set
      res.write head (418, headers) 
      res.end "I'm a teapot\n"
    timeout (1)
  
  authenticated request via proxy (username, password) (respond) =
    options = {
      url   = "http://127.0.0.1:9809/"
      proxy = "http://#(username):#(password)@127.0.0.1:9808/"
    }
    request (options) @(err, response, body)
      if (err) @ { throw (err) }
      respond(response, body)

  messages = []
  emit (name, data) =
    messages.push { name = name, data = data }
    
  proxy server = null
  
  before each @(ready)
    fake io = { sockets = { emit = emit } }
    proxy server = proxy.create server(fake io)
    proxy server.listen 9808
    teapot app.listen 9809
    ready()

  after each
    proxy server.close ()

  describe "a request with valid auth"

    it "prompts the user for credentials" @(done)
      authenticated request via proxy ("featurist", "cats") @(response, body)
        response.status code.should.equal(418)
        done()

  describe "a request with invalid auth"
    
    it "prompts the user for credentials" @(done)
      authenticated request via proxy ("bad", "zombie") @(response, body)
        body.should.equal('Please enter your Wiblr account details to continue')
        response.status code.should.equal(407)
        should.exist(response.headers.'proxy-authenticate')
        done()
