require 'mongo'

module DB
  
  def database
    @db ||= begin
      db = Mongo::Connection.new("localhost", 27017, safe: true).db("wiblr")
      db.authenticate("test", "password")
      db
    end
  end

  def exchanges_collection
    database.collection("exchanges")
  end
  
  def clear_exchanges
    exchanges_collection.remove({})
  end
  
  def clean_database
    clear_exchanges
  end
  
  def record_exchange(options = {})
    exchanges_collection.insert({
      "UUID" => UUID.new.to_s,
      "content-type" => 'text/json', 
      "time" => Time.now - (options[:seconds_ago] || 0), 
      "host" => "api.ihazmuzik.com", 
      "path" => (options[:path] || '/some/path'), 
      "status" => (options[:status] || 200)
    })
  end
  
end