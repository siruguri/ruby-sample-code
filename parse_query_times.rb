require 'json'

JSON.parse(File.open(ARGV[0]).readlines.join(' ').chomp).each do |item|
  puts [item['col0'], item['col2'].gsub(',', '')].join(',')
end

