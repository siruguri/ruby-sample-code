require 'rubygems'
require 'open-uri'
require 'nokogiri'

doc = Nokogiri::HTML(File.open("ahtml"))

ns = doc.xpath("//div[@class='mod-first-nav']")
ns1 = ns.xpath(".//a")

puts ns.length, ns1.length
ns1.each do |n|
  if n.name == "a"
    puts n.children[0]
  end
end
