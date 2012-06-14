test : spec
spec : js
	mogo spec/*.pogo

js :
	pogo -c src/public/js/*.pogo

scenarios : js
	bundle exec rspec -c docs/automation/*.rb

all : spec scenarios
  