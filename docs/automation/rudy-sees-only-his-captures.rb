require_relative "support/scenario_helper"

feature "Rudy sees only his captures" do
  include ScenarioHelpers
  
  scenario "after they have been stored in the database" do
    clean_database
    
    record_capture(user: 'rudy')
    record_capture(user: 'rudy')
    record_capture(user: 'woody')
    record_capture(user: 'woody')
    
    visit_dashboard
    load_captures
    
    dashboard_browser.all("#requests tbody tr").should have(2).items  
  end
    
end