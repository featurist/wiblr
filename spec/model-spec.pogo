model = require "../src/model"

describe "Capture"
  it "assigns itself a uuid before saving" @(done)
    capture = new (model.Capture)
    capture.save
      capture.uuid.length.should.equal(36)
      done()