pretty = require '../src/pretty'

describe 'pretty html'
  it 'prettifies html'
    pretty html = pretty.prettify (
      '<html><head></head><body><h1>hi!</h1><p>thing<br/>thang</p></body></html>'
      content type: 'text/html'
    )
    
    pretty html.should.equal '<html>
                                <head></head>
                                <body>
                                  <h1>hi!</h1>
                                  <p>thing      <br />
                              thang</p>
                                </body>
                              </html>
                              '

  it "doesn't prettify unknown mime-types"
    (pretty.prettify ('stuff', content type: 'text/anything')).should.equal 'stuff'
