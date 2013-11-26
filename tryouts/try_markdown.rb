require 'redcarpet'

input = '<link href="markdown.css" rel="stylesheet"></link>' + "\n"
input += File.open(ARGV[0]).readlines.join("")

parser = Redcarpet::Markdown.new(Redcarpet::Render::HTML_TOC)
toc = parser.render input

f=File.open('out.html', 'w')

# Print the TOC
 f.puts toc

# Change the quotes smartly
quoted_out = Redcarpet::Render::SmartyPants.render input

# Do the rest of the rendering
parser = Redcarpet::Markdown.new(Redcarpet::Render::HTML)

f.puts (parser.render quoted_out)

