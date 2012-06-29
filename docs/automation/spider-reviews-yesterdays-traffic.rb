require 'capybara/rspec'
require 'selenium-webdriver'
require 'childprocess'
require 'rest-client'
require 'mongo'
require 'date'
require 'UUID'

require File.join(File.dirname(__FILE__), "db")

include DB

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

Capybara.ignore_hidden_elements = true

def step(text)
  puts text
end


def setup_historical_capture(options)
  captures_collection.insert({"UUID" => UUID.new.to_s, "content-type" => 'text/json', "time" => @test_start_time - options[:seconds_ago], "host" => "api.ihazmuzik.com", "path" => options[:path], "status" => options[:status]})
end

feature "Review historical traffic" do
  background do
    @proxy_app_process = ChildProcess.build("pogo", "src/serve.pogo")
    @proxy_app_process.io.inherit! if ENV["INHERIT_IO"] == "true"

    @proxy_app_process.start.io.inherit!

    @watcher_browser = Capybara::Session.new(:chrome)

    @test_start_time = Time.now
  end

  before :each do
     clear_captures
  end

  after :each do
    Capybara.reset_sessions!
  end

  scenario "Spider reviews yesterdays traffic" do

    step("Spider receives a report of 404s trying to apply a voucher to a purchase
through his company's API from a client on the US west coast.

He sees no obvious explanation from the available logs,
so he sends the client a url to specific to them on his wiblr proxy:
  host: usclient.spider.wiblr.com
  port: 8080
and asks them to set these proxy settings then recreate the problem that night (uk time)
while he is in bed but they are all working.")

    #Insert historical data

    #Spider testing proxy is up beore going home
    setup_historical_capture(:seconds_ago => (60 * 60 * 12), :status => 200)
    setup_historical_capture(:seconds_ago => (60 * 60 * 12) + 5, :status => 200)

    #First client session
    session_start = (60 * 60 * 8) + (60 * 5)
    setup_historical_capture(:seconds_ago => session_start + 1,
                             :status => 200, :method => "GET", :path => '/catalogue/release/12345')

    setup_historical_capture(:seconds_ago => session_start + 1,
                             :status => 200, :method => "GET", :path => '/catalogue/release/12346')

    setup_historical_capture(:seconds_ago => session_start + 1,
                             :status => 200, :method => "GET", :path => '/catalogue/release/12347')

    setup_historical_capture(:seconds_ago => session_start + 1,
                             :status => 200, :method => "GET", :path => '/catalogue/release/12348')

    setup_historical_capture(:seconds_ago => session_start + 2,
                             :status => 200, :method => "GET", :path => '/catalogue/release/12348/track/67890')

    setup_historical_capture(:seconds_ago => session_start + 2,
                             :status => 200, :method => "POST", :path => '/basket/addtrack')

    setup_historical_capture(:seconds_ago => session_start + 4,
                             :status => 404, :method => "POST", :path => '/basket/applyvoocher')

    setup_historical_capture(:seconds_ago => session_start + 4,
                             :status => 404, :method => "POST", :path => '/basket/applyvoocher')

    setup_historical_capture(:seconds_ago => session_start + 5,
                             :status => 200, :method => "GET", :path => '/catalogue/release/555')

    setup_historical_capture(:seconds_ago => session_start + 5,
                             :status => 200, :method => "GET", :path => '/catalogue/release/556')

    setup_historical_capture(:seconds_ago => session_start + 5,
                             :status => 200, :method => "GET", :path => '/catalogue/release/557')


    step("The following morning, he browses to http://spider.wiblr.com, logs in, ")

    @watcher_browser.visit "http://127.0.0.1:8080"

    step("and browses to the usclient proxy logs.
He sees no recent traffic in the last 5 minutes")

    step("Spider loads the last 24 hrs traffic")
    
    @watcher_browser.should have_no_css("#requests tbody tr")

    @watcher_browser.select('24 hrs', :from => 'scale')
    
    @watcher_browser.find('#load').click()

    step("Spider scans through the traffic and spots the some 404s to /basket/applyvoocher

He emails his US clients to point out that they had voocher not voucher.")

    fourOhFour = @watcher_browser.find("#requests tbody tr.status-404")
    fourOhFour.should have_content('voocher')

  end
end
