module TryMod
  class String
    puts "Let's assign a method from the command line! Type in some alphabets."
    $meth = $stdin.gets.chomp
    puts "Right now, does String respond to #{$meth}? (Ruby says #{TryMod::String.new.respond_to?($meth.to_sym)})"
    self.send(:define_method, $meth.to_sym) do
    end
  end
  
  class Array
    def initialize(*args)
      args.each do |method_name|
        self.class.class_exec do

          define_method("#{method_name}") do
            eval "@#{method_name}"
          end
          define_method("#{method_name}=") do |inp|
            eval "@#{method_name}=inp"
          end
        end
      end
    end
  end
end

c=TryMod::Array.new(:a, :b)
puts c.respond_to? 'a'


puts "But now that we are all done reading the code, does String respond to #{$meth}? (Ruby says #{TryMod::String.new.respond_to?($meth.to_sym)})"
