# -*- coding: utf-8 -*-
require 'socket'

server = TCPServer.new 3000 # Server bound to port 4242

loop do
  client = server.accept
  client.write <<HEREDOC
<h1>Happy #{Time.now}!</h1>
HEREDOC

  puts "Sent mesg #{Time.now}."
  client.close
end
