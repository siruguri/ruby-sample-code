module TryMod
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

