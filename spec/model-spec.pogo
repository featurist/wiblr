model = require "../src/model"

describe "Capture"

  it "assigns itself a uuid before saving" @(done)
    capture = new (model.Capture)
    capture.save
      uuid = capture.uuid
      uuid.length.should.equal(36)
      done()
  
  it "only assigns itself a uuid once" @(done)
    capture = new (model.Capture)
    uuid = null
    
    capture.save
      uuid = capture.uuid
      
      capture.save
        capture.uuid.should.equal uuid
        done()

  it "sets the content length when the response body is set"
    capture = new (model.Capture)
    capture.set response body (new (Buffer "golly"))
    capture.content length.should.equal(5)

  it 'reads request body' @(done)
    capture = new (model.Capture)
    capture.request body = new (Buffer "golly")
    capture.save
      capture.read request body ().should.equal "golly"
      done ()

  it 'reads response body' @(done)
    capture = new (model.Capture)
    capture.set response body (new (Buffer "golly"))
    capture.save
      capture.read response body ().should.equal "golly"
      done ()
