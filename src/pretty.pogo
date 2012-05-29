jsdom = require 'jsdom'
dom to html = require('jsdom/lib/jsdom/browser/domtohtml').dom to html

pretty html (body) =
  dom = jsdom.jsdom (body, null)
  dom to html (dom)

exports.prettify (body, content type: content type) =
  if (r/^text\/html/.test (content type))
    pretty html (body)
  else
    body