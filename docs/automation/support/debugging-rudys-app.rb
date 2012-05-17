require 'selenium-webdriver'
require 'childprocess'

Capybara.register_driver :firefox_with_proxy do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new
  profile.proxy = Selenium::WebDriver::Proxy.new(:http => "127.0.0.1:8081")
  Capybara::Selenium::Driver.new(app, :profile => profile)
end

module DebuggingRudysApp
  attr_reader :watcher_browser
  attr_reader :proxied_browser
  
  def start_debugging_rudys_app
    @rudys_app_process = ChildProcess.build("pogo", "docs/automation/support/rudys-app.pogo")
    @proxy_app_process = ChildProcess.build("pogo", "src/app.pogo")
    
    @proxy_app_process.io.inherit! if ENV["INHERIT_IO"] == "true"
      
    @rudys_app_process.start
    @proxy_app_process.start
    
    @proxied_browser = Capybara::Session.new(:firefox_with_proxy)
    @watcher_browser = Capybara::Session.new(:selenium)
    
    @watcher_browser.visit "http://127.0.0.1:8080"
    @proxied_browser.visit "http://127.0.0.1:1337"
  end
  
  def stop_debugging_rudys_app
    @proxy_app_process.stop
    @rudys_app_process.stop
  end
end