require "./mongo"
mongoose = require "mongoose"
async = require "async"
uuid = require "node-uuid"
buffertools = require "buffertools"

ExchangeSchema = new (mongoose.Schema {
  uuid             = String
  response body    = Buffer
  request body     = Buffer
  content length   = Number
  time             = Date
  method           = String
  protocol         = String
  host             = String
  path             = String
  url              = String
  status           = Number
  request headers  = {}
  response headers = {}
} (strict: true))

ExchangeSchema.statics.since (from date) (callback) =
  this.find().where('time').gte(from date).sort('time', -1).exclude('responseBody').run (callback)

ExchangeSchema.methods.set response body (body buffer) =
  self.response body = body buffer
  self.content length = body buffer.length

ExchangeSchema.methods.has response body () =
  (self.status != -1) && (self.response body != nil)

decode base64 as utf8 (base64) =
  buffer = new (Buffer (base64, 'base64'))
  buffer.to string('utf-8')

ExchangeSchema.methods.read response body () =
  decode base64 as utf8 (self.response body)

ExchangeSchema.methods.read request body () =
  decode base64 as utf8 (self.request body)

ExchangeSchema.methods.can render response body as text() =
  content type (self.response headers.'content-type') is considered text

content type (content type) is considered text =
  !content type || content type.match (r/(text|css|javascript|json|xml)/)

ExchangeSchema.methods.can render request body as text() =
  content type (self.request headers.'content-type') is considered text

ExchangeSchema.pre 'save' @(next)
  if (!this.uuid)
    this.uuid = uuid.v4()
  
  next()

ExchangeSchema.methods.wire object() =
  {
    content length   = self.content length
    uuid             = self.uuid
    time             = self.time
    method           = self.method
    protocol         = self.protocol
    host             = self.host
    path             = self.path
    url              = self.url
    status           = self.status
    request headers  = self.request headers
    response headers = self.response headers
  }

Exchange = mongoose.model ('exchanges', ExchangeSchema)

module.exports = Exchange
