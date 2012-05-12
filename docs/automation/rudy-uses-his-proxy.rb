require 'capybara/rspec'
require 'selenium-webdriver'
require 'childprocess'

Capybara.register_driver :firefox_with_proxy do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new
  profile.proxy = Selenium::WebDriver::Proxy.new(:http => "127.0.0.1:8081")
  Capybara::Selenium::Driver.new(app, :profile => profile)
end

feature "Rudy uses his proxy" do
  background do
    @rudys_app_process = ChildProcess.build("pogo", "docs/automation/support/rudys-app.pogo")
    @proxy_app_process = ChildProcess.build("pogo", "src/app.pogo")
    
    @proxy_app_process.io.inherit! if ENV["INHERIT_IO"] == "true"
      
    @rudys_app_process.start
    @proxy_app_process.start
    
    @proxied_browser = Capybara::Session.new(:firefox_with_proxy)
    @watcher_browser = Capybara::Session.new(:selenium)
  end
  
  after do
    @proxy_app_process.stop
    @rudys_app_process.stop
  end

  scenario "and spies on another browser" do
    @watcher_browser.visit "http://127.0.0.1:8080"
    @proxied_browser.visit "http://127.0.0.1:1337"
    @watcher_browser.execute_script("$('#requests tbody tr:first').click()")    
    @proxied_browser.should have_content "Hello World"
    @watcher_browser.within_frame "response_body" do
      @watcher_browser.should have_css("textarea", :text => "Hello World")
    end
    
  end
end