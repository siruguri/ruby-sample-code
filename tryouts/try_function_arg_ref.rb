class Contain
  attr_accessor :my_arr
  def test_refs(arr_arg)
    @my_arr=arr_arg.clone
    @my_arr[0]=42
  end
  
  def print_arr
    return @my_arr[0]
  end

  def zero_arr(arr)
    arr.filter! { |t| nil }.compact!
  end
end

c=Contain.new
out_arr=[1,2,3]
c.test_refs(out_arr)

puts "arr has #{out_arr.size} size"
c.zero_arr out_arr
puts "arr has #{out_arr.size} size"
