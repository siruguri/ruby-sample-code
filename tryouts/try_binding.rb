begin
  puts not_defined
rescue Exception => e
  puts "Can variables be known before they are defined?"
  puts "No, they can't."
end
puts "But they are listed in local_variables: #{local_variables}"

not_defined=1
begin
  say_hello(not_defined)
rescue Exception => e
  puts "Can functions be known before they are defined?"
  puts "No, they can't."
end

def say_hello(val)
  puts val.to_s
end

class Sclass
  def yxme
    "y" + xme
  end

end
def xme
  "x"
end
#puts (Sclass.private_methods - Object.instance_methods).sort
#puts Object.private_methods.sort
s=Sclass.new
#puts Sclass.private_methods.sort
puts s.yxme
