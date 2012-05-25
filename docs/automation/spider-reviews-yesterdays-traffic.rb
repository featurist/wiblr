require 'capybara/rspec'
require 'selenium-webdriver'
require 'childprocess'
require 'rest-client'
require 'mongo'
require 'date'
require 'UUID'

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

def step(text)
  puts text
end

def database
  return @db unless @db.nil?

  connection = Mongo::Connection.new("localhost", 27017)
  @db = connection.db("wiblr")
  @db.authenticate("test", "password")
  @db
end

def captures_collection
  database.collection("capture")
end

def setup_historical_capture(options)
  captures_collection.insert({"UUID" => UUID.new.to_s, "time" => @test_start_time - options[:seconds_ago], "status" => options[:status]})
end

feature "Review historical traffic" do
  background do
    @proxy_app_process = ChildProcess.build("pogo", "src/app.pogo")
    @proxy_app_process.io.inherit! if ENV["INHERIT_IO"] == "true"

    @proxy_app_process.start.io.inherit!

    @watcher_browser = Capybara::Session.new(:chrome)

    @test_start_time = Time.now
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

    step("and browses to the usclient proxy logs and sees a graph representing the past 24 hrs' traffic.")

    @watcher_browser.select('24 hrs', :from => 'scale')

    step("He immediately spots a peak around 8hrs ago zooms into the that peak")

    destination = @watcher_browser.find(:css, "#graph li[data-time='#{@test_start_time - session_start}']")
    scrubber = @watcher_browser.find(:css, '#scrubber')
    scrubber.drag_to(destination) # OK, not quite that simple, but should be easy enough

    @watcher_browser.select('15 min', :from => 'scale')

    step("and scans through the traffic looking for calls to
the endpoint where the client had been reporting 404s.")

    fourOhFours = @watcher_browser.all("#requests tr.status-404")

    step("Spider scans through the traffic and spots the some 404s to /basket/applyvoocher

He emails his US clients to point out that they had voocher not voucher.")

    voocher_requests = fourOhFours.find_all do |request_row|
      request_row.has_content 'voocher'
    end

    voocher_requests.length.should be(2)

  end
end
