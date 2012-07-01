require_relative "support/scenario_helper"

feature "Rudy sees only his captures" do
  include ScenarioHelpers
  
  scenario "after they have been stored in the database" do
    clean_database
    
    setup_historical_capture(user: 'rudy')
    setup_historical_capture(user: 'rudy')
    setup_historical_capture(user: 'woody')
    setup_historical_capture(user: 'woody')
    
    visit_dashboard_and_wait_for_socket_connection
    load_captures
    
    dashboard_browser.all("#requests tbody tr").should have(2).items  
  end
    
end