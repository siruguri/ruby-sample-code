class Dog
  def self.legs
    4
  end
  
  def method_missing m
    return self.class.send m
  end
end

rover = Dog.new
puts rover.arms
