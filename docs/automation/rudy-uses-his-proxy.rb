require 'capybara/rspec'
require File.join(File.dirname(__FILE__), "support", "debugging-rudys-app")

feature "Rudy uses his proxy" do
  include DebuggingRudysApp
  
  background do
    start_debugging_rudys_app
  end
  
  after do
    stop_debugging_rudys_app
  end

  scenario "and captures http requests made by his browser" do
    watcher_browser.execute_script("$('#requests tbody tr:first').click()")    
    proxied_browser.should have_content "Hello World"
    watcher_browser.within_frame "response_body" do
      watcher_browser.should have_css("textarea", :text => "Hello World")
    end
  end
end