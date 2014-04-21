# Test how extend works to make a module simultaneously standalone and extendable

module Extendable
  def say_hello
    "Hello, my class is #{self.class}"
  end
  module_function :say_hello
  public :say_hello

end

class WillBeExtended
  extend Extendable

end

puts "This should say hello, with class Class: #{WillBeExtended.say_hello}"
puts "Finish the test by running try_module_usage.rb"
