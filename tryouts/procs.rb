def generic_return(code)
  puts code.call
  return "generic_return method finished"
end

puts generic_return(lambda { return "ret1"; return "ret2" })

def thrice
  yield
end

def call_and_print(fn)
  puts "in call_and_print"
  x='God'
  a=fn.call
  puts a
end

def return_behave
  puts "In return behave"

  x=42
  a=Proc.new do
    next "First defined in #{__method__} which contains the variables #{local_variables}"
  end

  ret=call_and_print a
  puts "call_and_print returned #{ret}"

  x='God'
  puts "Returning from #{__method__}"
  return a
end

def nested_scopes(func)
  sum=1
  [1,2].each { |x| func.call x }
  puts sum
end

x = 5
puts "value of x before: #{x}"
thrice { if !defined? y then y=0; end; y += 1; puts y }
puts "value of x and y after: #{x}"

fn=return_behave; puts fn.call

var='sum'
p1 = lambda { |x| code = "#{var} = #{var} + x";  eval code }

# shd print 3
sum=0;  [1,2].each { |x| p1.call x }; puts sum

# shd print 1 and 6
nested_scopes p1
puts sum

var='sum1'
# shd error out
begin
  sum=0;  [1,2].each { |x| p1.call x }; puts sum
rescue NoMethodError => e
  puts "Error when testing call #{e.message}"
end

# shd error out
begin
  nested_scopes p1
rescue NoMethodError => e
  puts "Error when testing nested_scopes #{e.message}"
end

