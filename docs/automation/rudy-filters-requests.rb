require 'capybara/rspec'
require File.join(File.dirname(__FILE__), "support", "debugging-rudys-app")

feature "Rudy filters requests" do
  include DebuggingRudysApp
  
  background do
    start_debugging_rudys_app
  end
  
  after do
    stop_debugging_rudys_app
  end

  scenario "and filters requests to those with 404 responses" do
    proxied_browser.visit "http://never-likely-to-exist"
    watcher_browser.fill_in "filter", :with => "404"
    watcher_browser.all("#requests tr").size.should == 1
  end
end