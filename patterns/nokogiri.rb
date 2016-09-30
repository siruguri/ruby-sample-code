require 'nokogiri'
require 'open-uri'

uri_str = 'http://www.spanishclassonline.com/vocabulary/occupationsProfessions.htm'
dom = Nokogiri::HTML.parse(open(uri_str).readlines.join(''))

divs = dom.xpath '/html/body/div[3]/center/table/tbody/tr/td/p'#/table/tbody/tr/td/table/tbody/tr'
divs.each_with_index do |d, i|
  #puts d.attribute('id')
  puts i
  puts d.text
end

