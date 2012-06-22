test : spec
spec : js
	mogo spec/*.pogo

js :
	pogo -cs src/public/js/*.pogo

scenarios : js
	bundle exec rspec -c docs/automation/*.rb

serve :
	pogo src/serve.pogo

tea :
	curl -x http://127.0.0.1:8081 http://www.httpbin.org/status/418 -v -U featurist:cats

google :
	curl -x http://127.0.0.1:8081 http://www.google.co.uk/ -v -U featurist:cats

post :
	curl -X POST http://www.httpbin.org/post -d 'field=stuff' -x http://localhost:8081/ -v -U featurist:cats

all : spec scenarios
  
