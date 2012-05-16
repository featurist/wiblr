test : spec/*.pogo
	pogo -c src/public/js/*.pogo && mogo spec/*.pogo && bundle exec rspec -c docs/automation/*.rb

spec : spec/*.pogo
	pogo -c src/public/js/*.pogo && mogo spec/*.pogo

scenarios : docs/automation/*.rb
	pogo -c src/public/js/*.pogo && bundle exec rspec -c docs/automation/*.rb