require 'chronic'
require 'csv'

f = File.open ARGV[0]
c = CSV.new f
c.each() do |row|
  if row.size > 1 and row[0]=~/20\d\d/
    date = Chronic.parse(row[0])
    puts date
  end
end
