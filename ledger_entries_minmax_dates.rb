require 'csv'

min_date = -1
min_period = -1
index = 0
CSV.foreach(ARGV[0]) do |fields|
  index += 1
  begin
    date = Date.strptime(fields[4], '%b %d %Y %H:%M%p')
  rescue
    next
  end

  period = Date.strptime(fields[5], '%b %d %Y %H:%M%p')
  if min_date == -1 || min_date > date
    min_date = date
  end
  if min_period == -1 || min_period > period
    min_period = period
  end

  puts index if index % 10000 == 1
end

puts min_date
puts min_period
