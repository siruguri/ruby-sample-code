require 'byebug'

require 'active_support/time'
require 'date'
require 'time'

# Pretty much based on http://stackoverflow.com/questions/279769/convert-to-from-datetime-and-time-in-ruby

DAYS = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', "Thursday", "Friday", "Saturday"]

# Make a time object from a string

# This was a Sunday
a = Date.parse('2015-04-12')

puts "Apr 12 in 2015 was a #{DAYS[a.wday]}"

# Converting Date to Time

b = a.to_time
puts "The time at midnight on that date was #{b}"

# What's the day tomorrow?
puts "The day tomorrow is #{DAYS[(Time.now+1.day).wday]}"


def tod_in_seconds(started_at)
  started_at.hour * 3600 + started_at.min * 60 + started_at.sec
end

# Two 15 today morning

a=Date.today
t=Time.new(a.year, a.month, a.day) + 2.hours + 15.minutes
puts "The number of seconds since the epoch time at 2 this morning was #{t.to_f}"

puts "The number of seconds since midnight at 2 this morning was #{tod_in_seconds(t)}"

def is_it_today?(datetime_obj)
  a=Date.today
  datetime_obj.year == a.year && datetime_obj.month == a.month && datetime_obj.day == a.day
end

puts "Yesterday is today? #{is_it_today?(Time.now - 1.day) ? 'yes' : 'no'}"
puts "Today is today? #{is_it_today?(Time.now) ? 'yes' : 'no'}"

