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

  