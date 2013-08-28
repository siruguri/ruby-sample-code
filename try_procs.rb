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

x = 5
puts "value of x before: #{x}"
thrice { if !defined? y then y=0; end; y += 1; puts y }
puts "value of x and y after: #{x}"

fn=return_behave
puts fn.call
