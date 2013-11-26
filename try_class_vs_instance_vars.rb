
class Animal
  def say
  end

  def number_of_legs
    self.class.number_of_legs
  end
  def self.number_of_legs
    @number_of_legs
  end
end

class Dog < Animal
  @number_of_legs=4
end

class Human < Animal
  @number_of_legs=2
end


d=Dog.new # 'rover'
h=Human.new # 'mike'

puts "Rover has #{d.number_of_legs} legs."
puts "Mike has #{h.number_of_legs} legs."

