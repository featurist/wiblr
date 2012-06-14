mongoose = require "mongoose"
async = require "async"
uuid = require "node-uuid"
buffertools = require "buffertools"

host = process.env.WIBLR_HOST || "http://localhost:8080"

mongo db = process.env.WIBLR_MONGO || 'mongodb://test:password@localhost:27017/wiblr'
mongoose.connect (mongo db) @(err)
  if (err)
    throw (new (Error("failed to connect to #(mongo db)\n#(err.to string())")))

CaptureSchema = new (mongoose. Schema {
  uuid             = String
  response body    = Buffer
  content type     = String
  time             = Date
  method           = String
  host             = String
  path             = String
  status           = Number
  request headers  = {}
  response headers = {}
} (strict: true))

CaptureSchema.statics.since (from date) (callback) =
  this.find().where('time').gte(from date).sort('time', -1).exclude('responseBody').run (callback)

CaptureSchema.methods.append response body (chunk) =
  self.response body = buffertools.concat(self.response body, chunk)

CaptureSchema.methods.has response body () =
  (self.status != -1) && (self.response body != nil)

CaptureSchema.methods.read response body () =
  decode base64 as utf8 (base64) =
    buffer = new (Buffer (base64, 'base64'))
    buffer.to string('utf-8')

  decode base64 as utf8 (self.response body)

CaptureSchema.methods.has text content type() =
  self.content type.match (r/(text|css|javascript|json|xml)/)

CaptureSchema.pre 'save' @(next)
  if (!this.uuid)
    this.uuid = uuid.v4()
    
  next()

CaptureSchema.methods.wire object() =
  {
    content type = self.content type
    uuid         = self.uuid
    time         = self.time
    method       = self.method
    host         = self.host
    path         = self.path
    status       = self.status
    request headers = self.request headers
    response headers = self.response headers
  }

Capture = mongoose.model ('captures', CaptureSchema)

exports.Capture = Capture