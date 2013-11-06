def options_hash(a, params)
  puts params.class
end
def options_hash_with_star(a, *params)
  puts params[0].class
end

def mid_hash(a, params, *params)
  puts b.class
  puts params.class
end


# should print Hash
options_hash(1, a: 2, b: 3)
# should print Hash
options_hash_with_star(1, a: 2, b: 3)

mid_hash(1, :a=>2, 4,5,6)
