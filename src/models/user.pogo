require './mongo'
mongoose = require "mongoose"

UserSchema = new (mongoose.Schema {
  username         = String
  password         = String
} (strict: true))

User = mongoose.model ('users', UserSchema)

User.create (options, created) =
  user = new (User)
  user.username = options.username
  user.save @(err)
    if (err) @{ throw (err) }
    created(err, user)

module.exports = User