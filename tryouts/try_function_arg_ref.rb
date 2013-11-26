class Contain
  attr_accessor :my_arr
  def test_refs(arr_arg)
    @my_arr=arr_arg.clone
    @my_arr[0]=42
  end
  
  def print_arr
    return @my_arr[0]
  end
end

c=Contain.new
out_arr=[1,2,3]
c.test_refs(out_arr)

print "#{out_arr[0]} passed to #{c.print_arr}\n"
out_arr[0]=84
print "#{out_arr[0]} passed to #{c.print_arr}\n"

