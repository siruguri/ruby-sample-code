require_relative 'net_http_fetch'

#n=NetHttpFetch.new('http://www.google.com')
#resp = n.get_url

n=NetHttpFetch.new('http://localhost:3000/bindb_add/400012')
n=NetHttpFetch.new('https://lit-mountain-3090.herokuapp.com/bindb_add/400012')
n=NetHttpFetch.new('http://localhost:3000/statuses')

n.post_data = { status: {source: 'password', description: 'test1', message: 'message-test'}}

resp = n.post_url

puts resp
