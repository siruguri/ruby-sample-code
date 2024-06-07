class MyClass
  attr_reader :name, :age

  def initialize(name, age)
    @name = name
    @age = age
  end

  def custom_method
    # Some other method
  end
end

my_object = MyClass.new("John", 30)

# Get a list of all methods
all_methods = my_object.methods

# Filter only attribute readers
attribute_readers = all_methods.select { |method| method.to_s.end_with?("?") }

puts attribute_readers
