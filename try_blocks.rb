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
y = 42

puts "value of x before: #{x}"
thrice { y += 1; puts y }
puts "value of x and y after: #{x}, #{y}"

