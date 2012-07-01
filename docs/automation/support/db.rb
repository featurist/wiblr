require 'mongo'

module DB
  
  def database
    @db ||= begin
      db = Mongo::Connection.new("localhost", 27017).db("wiblr")
      db.authenticate("test", "password")
      db
    end
  end

  def captures_collection
    database.collection("captures")
  end
  
  def clear_captures
    captures_collection.remove
  end
  
  def clean_database
    clear_captures
  end
  
  def setup_historical_capture(options = {})
    captures_collection.insert({
      "UUID" => UUID.new.to_s,
      "content-type" => 'text/json', 
      "time" => (options[:seconds_ago] || Time.now.to_i - 2), 
      "host" => "api.ihazmuzik.com", 
      "path" => (options[:path] || '/some/path'), 
      "status" => (options[:status] || 200)
    })
  end
  
end