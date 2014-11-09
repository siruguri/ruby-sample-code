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

puts "value of x before should be 5: #{x==5}"
thrice { y += 1 }
puts "value of x and y after should be 5 and 45: #{x==5}, #{y==45}"

def multiple_scopes(&blk)

  blk.call

end

a=2
multiple_scopes { a+=1 }
puts "a should be 3: #{a==3}"
