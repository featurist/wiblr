Exchange = require '../../src/models/exchange'

describe "Exchange"

  it "assigns itself a uuid before saving" @(done)
    exchange = new (Exchange)
    exchange.save
      uuid = exchange.uuid
      uuid.length.should.equal(36)
      done()
  
  it "only assigns itself a uuid once" @(done)
    exchange = new (Exchange)
    uuid = null
    
    exchange.save
      uuid = exchange.uuid
      
      exchange.save
        exchange.uuid.should.equal uuid
        done()

  it "sets the content length when the response body is set"
    exchange = new (Exchange)
    exchange.set response body (new (Buffer "golly"))
    exchange.content length.should.equal(5)

  it 'reads request body' @(done)
    exchange = new (Exchange)
    exchange.request body = new (Buffer "golly")
    exchange.save
      exchange.read request body ().should.equal "golly"
      done ()

  it 'reads response body' @(done)
    exchange = new (Exchange)
    exchange.set response body (new (Buffer "golly"))
    exchange.save
      exchange.read response body ().should.equal "golly"
      done ()
