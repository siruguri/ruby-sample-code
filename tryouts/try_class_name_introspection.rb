require 'byebug'
module Container
  def majority
    puts self.to_s
    false
  end
end

class Parent
  def name_klass
    self.class.to_s
  end
end

class Child < Parent
  extend Container
  def greet
    "my name is #{name_klass}"
  end

  def old_enough?
    self.class.majority
  end
end

require 'minitest/autorun'

describe Child do
  before do
    @child = Child.new
  end
  
  it 'greets correctly' do
    assert_equal 'my name is Child', @child.greet
  end

  it 'is not old enough' do
    assert_equal false, @child.old_enough?
  end
end

