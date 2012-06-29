require_relative "support/scenario_helper"

include DB

feature "Rudy sees only his captures" do
  
  background do
    clean_database
  end
  
  scenario "after they have been stored in the database" do
    setup_historical_capture(user: 'rudy')
    setup_historical_capture(user: 'rudy')
    setup_historical_capture(user: 'woody')
    setup_historical_capture(user: 'woody')
    
    visit_dashboard
    load_captures
    
    dashboard_browser.all("#requests tbody tr").size.should == 2    
  end
    
end