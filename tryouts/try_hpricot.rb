require 'hpricot'
require 'open-uri'

doc = open("../../bookmarks.html") { |f| Hpricot(f) }

def traverse_dom (node, level=0)
  yield node
  if node.responds_to :children then
    node.children.each { |n| traverse_dom(n, level+1) }
  end
end

traverse_dom x.xpath('/') do |node|

