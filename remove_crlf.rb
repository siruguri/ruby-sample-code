File.open(ARGV[0]).readlines.each do |line|
  line.chomp!
  puts line
end
