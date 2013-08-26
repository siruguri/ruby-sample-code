require 'sqlite3'

db = SQLite3::Database.new(ARGV[0])

rows = db.execute (ARGV[1])

rows.each do |row|
  puts row.to_s
end
