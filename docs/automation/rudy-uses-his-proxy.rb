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
    @hello_app_process = ChildProcess.build("pogo", "docs/automation/support/hello-world-app.pogo")
    @proxy_app_process = ChildProcess.build("pogo", "app.pogo")
    @hello_app_process.start
    @proxy_app_process.start
    @proxied_browser = Capybara::Session.new(:firefox_with_proxy)
    @watcher_browser = Capybara::Session.new(:selenium)
  end
  
  after do
    @proxy_app_process.stop
    @hello_app_process.stop
  end

  scenario "and spies on another browser" do
    @watcher_browser.visit "http://127.0.0.1:8080"
    @proxied_browser.visit "http://127.0.0.1:1337"
    @watcher_browser.should have_css("#captures tr td", :text => "http://127.0.0.1:1337")
    @watcher_browser.should have_css("#captures tr td", :text => "Hello World")
  end
end