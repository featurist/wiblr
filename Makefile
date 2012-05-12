test : spec/*.pogo
	mogo spec/*.pogo

spec : spec/*.pogo
	mogo spec/*.pogo

scenarios : docs/automation/*.rb
	bundle exec rspec -c docs/automation/*.rb