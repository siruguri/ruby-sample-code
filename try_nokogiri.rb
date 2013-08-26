require 'nokogiri'
require 'open-uri'

dom=Nokogiri::HTML(open(ARGV[0]))

dl_root=dom.xpath('a')

puts dl_root

dl_root.each do |node|
  puts node
end

