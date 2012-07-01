require 'capybara/rspec'

require_relative "db"
require_relative "browser"
require_relative "apps"

module ScenarioHelpers

  include DB
  include Browser
  include Apps

  def step(text)
    puts text
  end

end