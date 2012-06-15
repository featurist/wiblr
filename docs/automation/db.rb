require 'mongo'

module DB
  
  def database
    return @db unless @db.nil?

    connection = Mongo::Connection.new("localhost", 27017)
    @db = connection.db("wiblr")
    @db.authenticate("test", "password")
    @db
  end

  def captures_collection
    database.collection("captures")
  end
  
  def clear_captures
    captures_collection.remove
  end
  
end