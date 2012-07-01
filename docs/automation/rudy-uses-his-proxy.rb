require_relative "support/scenario_helper"

include DB

feature "Rudy uses his proxy" do
  background do
    @rudys_app_process = ChildProcess.build("pogo", "docs/automation/support/rudys-app.pogo")
    @proxy_app_process = ChildProcess.build("pogo", "src/serve.pogo")
      
    @rudys_app_process.start.io.inherit!
    @proxy_app_process.start.io.inherit!
    
    @dashboard_browser = Capybara::Session.new(:chrome)
  end
  
  before :each do
    clear_captures
  end
  
  after :each do
    @proxy_app_process.stop
    @rudys_app_process.stop
    Capybara.reset_sessions!
  end

  scenario "and spies on another browser" do
    @dashboard_browser.visit "http://127.0.0.1:8080"
    @dashboard_browser.should have_css("body.connected")
    proxied_response = visit_through_proxy "http://127.0.0.1:1337"

    @dashboard_browser.find(:css, "#requests tbody tr").click
    proxied_response.should include "Hello World"

    @dashboard_browser.within_frame "response-body" do
      @dashboard_browser.should have_css("pre code", :text => "Hello World")
    end
    
  end
  
  scenario "and spies on a long-running request, seeing first the request then the response" do
    @dashboard_browser.visit "http://127.0.0.1:8080"
    @dashboard_browser.should have_css("body.connected")
    
    proxy_request_thread = Thread.new do
      visit_through_proxy "http://127.0.0.1:1337/slow"
    end
    
    original_wait_time = Capybara.default_wait_time
    begin
      @dashboard_browser.find('.host').should have_content('127.0.0.1')
      Capybara.default_wait_time = 0
      @dashboard_browser.all('.status').first.should_not have_content('200')
    
      Capybara.default_wait_time = 0.5
      @dashboard_browser.find('.status').should have_content('200')
    ensure
      Capybara.default_wait_time = original_wait_time
    end
    
    proxy_request_thread.join
  end
  
end
