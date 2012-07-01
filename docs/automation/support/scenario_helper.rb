require 'capybara/rspec'
require 'selenium-webdriver'
require 'childprocess'
require 'rest-client'
require 'uuid'

require_relative "db"

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end
Capybara.ignore_hidden_elements = true

module ScenarioHelpers

  def visit_through_proxy (url)
    RestClient.proxy = "http://featurist:cats@127.0.0.1:8081"
    RestClient.get url
  end

  def step(text)
    puts text
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

  def dashboard_browser
    @dashboard_browser ||= Capybara::Session.new(:chrome)
  end

  def visit_dashboard
    dashboard_browser.visit "http://127.0.0.1:8080"
  end

  def load_captures
    dashboard_browser.click_button 'Load'
  end

  def clean_database
    captures_collection.remove
  end

end