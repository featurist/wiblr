*** Dev Environment ***

Install prerequisites:

    npm install
    bundle install
    brew install mongodb

In a mongo shell:

    use wiblr
    db.addUser("test", "password") 

Running it:

    pogo src/serve.pogo
