User = require "../../src/models/user"
should = require 'should'

describe "User"
  it "can be created" @(done)
    User.create {username = 'rudy', password = 'secret'} @(err, created user)
      if (err) @{ throw "oops" }
      User.find one( { _id = created user._id } ) @(err, stored user)
        if (err) @{ throw (err) }
        should.exist(stored user)
        stored user.username.should.equal("rudy")
        done()