begin
  b="hello world!"
  puts b
  
  r=Regexp.new("**")
rescue NameError => e
  puts "Local var undefined? #{e.message}"
rescue RegexpError => e
  puts "Something can't be parsed in a regex? #{e.message}"
else
  puts "Something I don't know about."
end
