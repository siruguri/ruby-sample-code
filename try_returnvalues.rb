# This helps me keep track of how functions return values
# Great place to learn how to use TDD, rspec etc.

def return_array
# doesn't work  1, 2

# works
  [1,2]

# doesn't work  (1,2)
end

arr=return_array
x,y=return_array

# it "should return array"
puts arr.class # shd return Array
puts arr.count # shd return 2

puts x.class #shd return Fixnum
puts x+2 #shd return 3
