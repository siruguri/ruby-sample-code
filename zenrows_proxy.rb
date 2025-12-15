# gem install faraday
require 'faraday'

url = 'https://twobliving.appfolio.com/users/sign_in'
proxy = "http://#{ENV['ZENROWS_TOKEN']}:@api.zenrows.com:8001"
conn = Faraday.new(proxy: proxy, ssl: {verify: false})
conn.options.timeout = 180
res = conn.get(url, nil, nil)
print(res.body)

