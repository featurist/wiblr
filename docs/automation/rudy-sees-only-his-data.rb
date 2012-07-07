require_relative "support/scenario_helper"

feature "Rudy sees only his data" do
  include ScenarioHelpers
  
  scenario "historically" do
    start_wiblr
    clean_database
    
    record_exchange(user: 'rudy')
    record_exchange(user: 'rudy')
    record_exchange(user: 'woody')
    record_exchange(user: 'woody')
    
    visit_dashboard
    load_exchanges
    
    dashboard_browser.all("#requests tbody tr").should have(2).items  
  end
    
end