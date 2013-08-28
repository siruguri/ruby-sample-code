b=binding

a=1

c= b.eval('local_variables')
c.each do |var|
  puts "Local variable: #{var}"
end


