require 'redcarpet'

input = File.open(ARGV[0]).readlines.join("")

parser = Redcarpet::Markdown.new(Redcarpet::Render::HTML_TOC)
toc = parser.render input

f=File.open('out.html', 'w')

f.puts(toc)

parser = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
f.puts(parser.render input)
