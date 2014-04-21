# Test what namespace exists inside a module for class names

class MyClass
  def hello
    'outside hello'
  end
end

module TryMod
  class MyClass
    def hello
      'hello'
    end
  end

  class InternalClass
    def initialize
      c=MyClass.new
      @mesg = c.hello # Should print hello
    end

    def mesg
      @mesg
    end
  end
end

class ExternalClass
  def initialize
    c=MyClass.new
    @mesg = c.hello # Should print hello
  end

  def mesg
    @mesg
  end
end


puts "This should output hello, not 'my hello': #{TryMod::InternalClass.new.mesg}" # should print hello
puts "This should output 'outside hello', not 'hello': #{ExternalClass.new.mesg}" # should print hello
