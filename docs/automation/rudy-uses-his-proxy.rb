require 'capybara/rspec'
require 'selenium-webdriver'
require 'childprocess'
require 'rest-client'
require File.join(File.dirname(__FILE__), "db")

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

def visit_through_proxy (url)
  RestClient.proxy = "http://featurist:cats@127.0.0.1:8081"
  RestClient.get url
end 

include DB

feature "Rudy uses his proxy" do
  background do
    @rudys_app_process = ChildProcess.build("pogo", "docs/automation/support/rudys-app.pogo")
    @rudys_slow_app_process = ChildProcess.build("pogo", "docs/automation/support/rudys-slow-app.pogo")
    @proxy_app_process = ChildProcess.build("pogo", "src/serve.pogo")
    
    @proxy_app_process.io.inherit! if ENV["INHERIT_IO"] == "true"
      
    @rudys_app_process.start.io.inherit!
    @rudys_slow_app_process.start.io.inherit!
    @proxy_app_process.start.io.inherit!
    
    @watcher_browser = Capybara::Session.new(:chrome)
  end
  
  before :each do
    clear_captures
  end
  
  after :each do
    @proxy_app_process.stop
    @rudys_app_process.stop
    @rudys_slow_app_process.stop
    
    Capybara.reset_sessions!
  end

  scenario "and spies on another browser" do
    @watcher_browser.visit "http://127.0.0.1:8080"
    @watcher_browser.should have_css("body.connected")
    proxied_response = visit_through_proxy "http://127.0.0.1:1337"

    @watcher_browser.find(:css, "#requests tbody tr").click
    proxied_response.should include "Hello World"

    @watcher_browser.within_frame "response-body" do
      @watcher_browser.should have_css("pre code", :text => "Hello World")
    end
    
  end
  
  scenario "and spies on a long-running request, seeing first the request then the response" do
    @watcher_browser.visit "http://127.0.0.1:8080"
    @watcher_browser.should have_css("body.connected")
    
    proxy_request_thread = Thread.new do
      visit_through_proxy "http://127.0.0.1:5100"
    end
    
    original_wait_time = Capybara.default_wait_time
    begin
      @watcher_browser.find('.host').should have_content('127.0.0.1')
      Capybara.default_wait_time = 0
      @watcher_browser.all('.status').first.should_not have_content('200')
    
      Capybara.default_wait_time = 0.5
      @watcher_browser.find('.status').should have_content('200')
    ensure
      Capybara.default_wait_time = original_wait_time
    end
    
    proxy_request_thread.join
  end
  
end
