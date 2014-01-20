# Test what namespace exists inside a module for class names

class MyClass
  def hello
    puts 'my hello'
  end
end

module TryMod
  class MyClass
    def hello
      puts 'hello'
    end
  end

  class TryClass
    def initialize
      c=MyClass.new
      c.hello # Should print hello
    end
  end
end

m=TryMod::TryClass.new # should print hello
