def generic_return(code)
  puts code.call
  return "generic_return method finished"
end

puts generic_return(lambda { return "ret1"; return "ret2" })

def thrice
  yield
  yield
  yield
end
 
x = 5
puts "value of x before: #{x}"
thrice { if !defined? y then y=0; end; y += 1; puts y }
puts "value of x and y after: #{x}"
