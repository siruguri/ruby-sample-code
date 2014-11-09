lines_read=0
f=File.open ARGV[0]

until lines_read >= 100000 or f.eof?
  buffer = f.read 1
  # Do something with buffer
  print buffer

  # Sample - change LF to CRLF
  if buffer == "\r"
    lines_read += 1
    puts
  end
end
