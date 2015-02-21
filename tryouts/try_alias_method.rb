### Using alias_method

class Boss
  def name
    p "Ramu"
  end
  def self.apply_alias
    # diff behavior if you say -- alias :full_name :name
    alias_method :full_name, :name
  end
  apply_alias
end

class Employee < Boss
  def name
    p "Sheela"
  end
  apply_alias

end

puts "Checking base method on base class: #{Boss.new.name == 'Ramu'}"
puts "Checking base method on sub class: #{Employee.new.name == 'Sheela'}"
puts "Checking sub method on base class: #{Boss.new.full_name == 'Ramu'}"
puts "Checking sub method on sub class: #{Employee.new.full_name == 'Sheela'}"
