class A
end

puts "class responds to meth: #{A.respond_to? :meth}"

class A
  def self.meth
  end
end

puts "class responds to meth: #{A.respond_to? :meth}"

puts "class responds to meth2: #{A.respond_to? :meth2}"
class A
  self.class.send(:define_method, :meth2) do
  end
end

puts "class responds to meth2: #{A.respond_to? :meth2}"

class B
end

puts "should be false: #{B.respond_to? :meth2}"
