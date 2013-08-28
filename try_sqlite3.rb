require 'sqlite3'

db = SQLite3::Database.new( ARGV[0] )
rows = db.execute( "SELECT * FROM sqlite_master WHERE type='table'" )
rows.each { |x|
  puts x
}

