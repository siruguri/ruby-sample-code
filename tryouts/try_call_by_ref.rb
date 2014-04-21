# Testing what the scoping of method arguments is 

def change_value(inp)
  if inp.is_a?(Hash)
    inp.merge({add: 1})
  end
end

h = {sub: 1}
h = change_value h

puts "#{h} should have two keys."

h = {add: 2}
h = change_value h

puts "#{h[:add]} should be 1."
