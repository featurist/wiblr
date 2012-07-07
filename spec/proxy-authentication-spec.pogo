proxy = require "../src/proxy"
model = require "../src/model"

request = require 'request'
http = require 'http'
should = require 'should'
teapot = require './support/teapot'
user model = require '../src/models/user'

describe "proxy"
  
  authenticated request via proxy (username, password) (respond) =
    request via proxy (respond, proxy url: "http://#(username):#(password)@127.0.0.1:9808/")

  request via proxy (respond, proxy url: "http://127.0.0.1:9808/") =
    options = {
      url   = "http://127.0.0.1:9809/teapot"
      proxy = proxy url
    }
    request (options) @(err, response, body)
      if (err) @ { throw (err) }
      respond(response, body)

  messages = []
  emit (name, data) =
    messages.push { name = name, data = data }
    
  proxy server = null
  teapot app = null
    
  create user (created) =
    user model.create {username = 'rudy', password = 'secret'} @(err, user)
      created (user)
  
  user = null
  
  before each @(ready)
    teapot app = teapot.create teapot app()
    fake io = { sockets = { emit = emit } }
    proxy server = proxy.create server(fake io)
    proxy server.listen 9808
    teapot app.listen 9809
    create user @(created user)
      user = created user
      ready()

  after each
    proxy server.close()
    teapot app.close()

  describe "a request with valid auth"
    it "is proxied successfully" @(done)
      authenticated request via proxy (user.login, user.password) @(response, body)
        response.status code.should.equal(418)
        done()
        
  describe "no auth"
    it "prompts the user for credentials" @(done)
      request via proxy @(response, body)
        body.should.equal('Please enter your Wiblr account details to continue')
        response.status code.should.equal(407)
        should.exist(response.headers.'proxy-authenticate')
        done()
      
  describe "a request with invalid auth"
    it "prompts the user for credentials" @(done)
      authenticated request via proxy ("bad", "zombie") @(response, body)
        body.should.equal('Please enter your Wiblr account details to continue')
        response.status code.should.equal(407)
        should.exist(response.headers.'proxy-authenticate')
        done()
