# this experiments with how .send behaves

class Foo
  def greet(x)
    puts "Hello, #{x}!"
  end
end

def free_stander(x)
  x+1
end

bar=Foo.new

# these two shd be the same

x="sameer"
bar.greet(x)
bar.send(:greet, x)

ret=Object.send(:free_stander, 1)

puts "You should see 2 now."
puts ret # shd return 2

class Object
  def send(*args)
    puts "I won't send any more."
  end
end

puts "You should not see 43 now."
ret=free_stander(42)
puts ret


