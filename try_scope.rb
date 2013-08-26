x=1
class Dog
  def initialize(x)
    @name = x
  end


  def speak
    word = "yap"
    yield @name
  end
end

d=Dog.new("rover")

word = "bow"
d.speak { |name| puts "#{name} says #{word}" }
