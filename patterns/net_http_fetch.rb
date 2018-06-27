# http://www.rubyinside.com/nethttp-cheat-sheet-2940.html~

require 'net/https'
require 'uri'

uri = URI.parse 'https://sfbay.craigslist.org/search/sss'
params = {query: 'mrx', sort: 'rel'}
uri.query = URI.encode_www_form params 

http_conn = Net::HTTP.new(uri.host, uri.port)
http_conn.use_ssl = true

# Sometimes this is necessary
# http.verify_mode = OpenSSL::SSL::VERIFY_NONE

# Shortcut
req = Net::HTTP::Get.new uri
response = http_conn.request req

# Will print response.body
puts response.body

