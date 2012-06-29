require 'capybara/rspec'
require 'selenium-webdriver'
require 'childprocess'
require 'rest-client'
require 'uuid'

require_relative "db"

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

def visit_through_proxy (url)
  RestClient.proxy = "http://featurist:cats@127.0.0.1:8081"
  RestClient.get url
end

Capybara.ignore_hidden_elements = true

def step(text)
  puts text
end

def setup_historical_capture(options)
  captures_collection.insert({"UUID" => UUID.new.to_s, "content-type" => 'text/json', "time" => @test_start_time - options[:seconds_ago], "host" => "api.ihazmuzik.com", "path" => options[:path], "status" => options[:status]})
end
