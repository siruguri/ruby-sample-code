# Code in a yielded block is evaluated in the context of the block's
# scope, unless the block is expliclity eval'ed in a different scope

class Dog
  def initialize(name)
    @name=name
  end
  def speak
    yield @name
  end
  def add_fn
    yield if block_given?
  end
end

d=Dog.new('rover')
d.speak do |n|
  puts "My name is #{n}."
  def just_a_fn
    puts "It was a function."
  end
end

d.add_fn do
  puts "in block"
  def just_a_fn
    puts @name
  end

end

puts "You should see the text 'It was a function'."
just_a_fn

puts "Calling just a fn..."
d.just_a_fn

