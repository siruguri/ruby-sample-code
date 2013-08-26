class Animal
  @sound="peep"
  
  def self.sound
    @@sound
  end

end

class Dog < Animal
  def self.sound=(val)
    self.
  end
end

puts Animal.sound
Dog.sound="bark"
puts Animal.sound
