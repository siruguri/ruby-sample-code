require 'nokogiri'
require 'shell'

puts "<<#{__FILE__}>>", ARGV[0], ARGV.length
puts ENV["OS"]

begin
  this_fails
rescue Exception => e
  puts e.class
end

mesg_type = "no change"
mesg = "START: "
mesg = mesg +
  (case mesg_type
  when "no change"
    "nothing changed"
  when "changed"
    "something changed"
  when "fetch fail"
    "the fetch failed"
  end) + "."

puts mesg

#puts `diff client_code.rb server_listen.rb`

def fn1(str)
  puts str + "Fn1"
end

def find_diff_rule(str)
  rules = [:fn1]
  rules.each do |diff_fn|
    self.method(diff_fn).call(str)
  end
end

find_diff_rule("hello")

class Dog
  define_method ("my_bark") do
    "bark"
  end
end

d=Dog.new
puts d.send(:my_bark)

puts ENV["TWITTER_API_KEY"], ENV["TWITTER_CONSUMER_SECRET"]
