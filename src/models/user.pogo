mongoose = require "mongoose"
require '../mongo'

UserSchema = new (mongoose.Schema {
  username         = String
  password         = String
} (strict: true))

User = mongoose.model ('users', UserSchema)

exports.create (options, created) =
  user = new (User)
  user.username = options.username
  user.save @(err)
    if (err) @{ throw (err) }
    created(err, user)

exports.find one() =
  User.find one.apply(User, arguments)
  