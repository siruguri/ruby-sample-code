a = '1'
case a
when Integer
  puts 'int'
when String
  puts 'string'
end
puts ('String' === a ? 'yeah' : 'nope')
puts (a === 'String' ? 'yeah' : 'but not commutative')
