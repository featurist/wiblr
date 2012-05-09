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
    @process = ChildProcess.build("pogo", "app.pogo")
    #@process.io.inherit!
    @process.start
    @proxied_browser = Capybara::Session.new(:firefox_with_proxy)
    @watcher_browser = Capybara::Session.new(:selenium)
  end
  
  after do
    @process.stop
  end

  scenario "and spies on another browser" do
    @watcher_browser.visit "http://127.0.0.1:8080"
    @proxied_browser.visit "http://www.google.com"
    @watcher_browser.should have_css("#captures tr td", :text => "http://www.google.com")
  end
end