mongoose = require "mongoose"

host = process.env.WIBLR_HOST || "http://localhost:8080"

connection string = process.env.WIBLR_MONGO || 'mongodb://test:password@localhost:27017/wiblr'
mongoose.connect (connection string) @(err)
  if (err)
    throw (new (Error("failed to connect to #(connection string)\n#(err.to string())")))