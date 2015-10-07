f = File.open(ARGV[0], 'wb')

str = <<HERED


    <html>
    <head>
    <meta http-equiv="Content-Type" content="text/html; ">

HERED

f.write str

ARGV[1..-1].each do |byte|
  f.write([byte.to_i].pack('C'))
end
f.write("\n" + '</body>' + "\n")
f.close
