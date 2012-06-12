WIBLR_HOST=http://54.247.172.188:8080 \
forever start -o out.log -e err.log -c /usr/bin/pogo src/serve.pogo