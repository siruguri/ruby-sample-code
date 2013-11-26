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
puts ret # shd return 2

