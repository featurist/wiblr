require 'selenium-webdriver'
require 'rest-client'
require 'uuid'

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end
Capybara.ignore_hidden_elements = true

module Browser
  def dashboard_browser
    @@dashboard_browser ||= Capybara::Session.new(:chrome)
  end

  def visit_dashboard
    dashboard_browser.visit "http://127.0.0.1:8080"
    dashboard_browser.should have_css("body.connected")
  end
  
  def visit_through_proxy (url)
    RestClient.proxy = "http://featurist:cats@127.0.0.1:8081"
    RestClient.get url
  end
  
  def load_exchanges
    dashboard_browser.click_button 'Load'
  end
end