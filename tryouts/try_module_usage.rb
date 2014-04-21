# This assumes the Extendable module in try_module_extend.rb

require_relative "./try_module_extend"

puts "This should say hello with a Module class: #{Extendable.say_hello}"

