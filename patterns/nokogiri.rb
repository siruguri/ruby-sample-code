require 'nokogiri'
require 'open-uri'

uri_str = 'http://www.google.com'
dom = Nokogiri::HTML.parse(open(uri_str).readlines.join(''))

divs = dom.css 'div'
divs.each  { |d| puts d.attribute('id') }
