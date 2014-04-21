# What does class eval do?

class Dog
  def initialize(name)
    @name=name
  end
  def speak
    yield @name
  end

  def method_missing(sym)
    if sym == :bark
      self.class.bark
    end
  end
end
def do_barks(d)
  d.bark
  Dog.new('not rover').bark
end

d=Dog.new('molly')
d.class.instance_eval do
  def bark
    puts "class: I'm rover now."
  end
end

puts "Expect: 3x class:I'm rover now"
do_barks(d)
Dog.bark

Dog.class_eval do
  def bark
    speak do |n|
      puts "Bow wow #{n}"
    end
  end
end

puts "Expect: Bow wow rover"
d=Dog.new('rover')
d.bark

d.instance_eval do
  def bark
    puts "I'm rover now."
  end
end

puts "Expect: i'm rover now, bow wow not rover"
do_barks(d)

d.class.class_eval do
  def bark
    puts "I'm rover now."
  end
end

puts "Expect: i'm rover now (twice)"
do_barks(d)

