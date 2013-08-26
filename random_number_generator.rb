CHARS = (?A..?Z).to_a + (?0..?9).to_a + (?a..?z).to_a + ['!', '@', '#', '$', '%', '^', '&', '*', '(', ')']
api_string = 8.times.inject("") {|s, i| s << CHARS[rand(CHARS.size)]}


re1=Regexp.new '^[a-z]'

if re1.match api_string then
  print "Starts with lowercase\n"
end

print api_string
