class Person
  @count = 0

  @name = "sameer is god"

  def initialize(name)
    @name=name
    puts "Hi, #{name}"
    self.class.count += 1
    self.class.name += "and of #{name} too"
  end

  def self.name
    @name
  end

  def self.name=(value)
    @name = value
  end

  def self.count
    @count
  end
  def self.count=(value)
    @count = value
  end

  def name
    @name
  end
end

arr=[]
5.times { |i| arr << Person.new("#{i}") }
puts "Pop: #{Person.count}; God: #{Person.name}"

puts arr[1].name
