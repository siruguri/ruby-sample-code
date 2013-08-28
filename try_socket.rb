# -*- coding: utf-8 -*-
require 'socket'

server = TCPServer.new 3000 # Server bound to port 4242

loop do
  puts "Going into thread"
  Thread.start(server.accept) do |client|    # Wait for a client to connect
    client.write "HTTP/1.0 200 OK"
    client.write <<HEREDOC
Content-Type: text/html

<html>
<body>
<h1>Happy New Millennium!</h1>
</body>
</html>
HEREDOC

    puts "Sent mesg #{Time.now}."
    client.close
  end
end
