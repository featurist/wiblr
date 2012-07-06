mongoose = require "mongoose"

mongo db = process.env.WIBLR_MONGO || 'mongodb://test:password@localhost:27017/wiblr'
mongoose.connect (mongo db) @(err)
  if (err)
    throw (new (Error("failed to connect to #(mongo db)\n#(err.to string())")))

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
  