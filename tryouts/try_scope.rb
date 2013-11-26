x=1

def function_scope
  # This won't work unless you comment out both lines
  # x=1
  # puts x
end

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
function_scope
