require 'oauth2'

client_name = ARGV[0] || 'sc'

oauth_provider_info=Hash.new
oauth_provider_info['admin']={}
oauth_provider_info['admin-heroku']={}
oauth_provider_info['sc-heroku']={}
oauth_provider_info['sc']={}

oauth_provider_info['admin'][:clientid] = "96dd24520491c17f4bd5bca7d730387dcbb5b4bb0dfe17ed6a7a03ef0c867ca9"
oauth_provider_info['admin'][:secret] = "77d3fb2eccc3cb762a73f4bf6ba8e683d847c0429f40f07e3d76d61bc2da5846"
oauth_provider_info['admin'][:redirect_uri] = "http://localhost:4000/redirect_from_oauth/admin"
oauth_provider_info['admin'][:site] = "http://localhost:3000"

oauth_provider_info['admin-heroku'][:clientid] = "df49016d921f3924f447819e7ea330e9d77328314be7f6b390e64d9732448308"
oauth_provider_info['admin-heroku'][:secret] = "8e0c6fd589940dba4a7b1ec78ce03f6e31fd56b8cdbbecda5f293bb56ff9782c"
oauth_provider_info['admin-heroku'][:redirect_uri] = "http://localhost:4000/redirect_from_oauth/admin"
oauth_provider_info['admin-heroku'][:site] = "http://eventually-ss.herokuapp.com:80/" 

oauth_provider_info['sc'][:clientid] = "68079586ca53d9d43ff5cba119095422d46b3d8164aab8afb4a01172b9bfe943"
oauth_provider_info['sc'][:secret] = "5e3f90117965c7c5530a4ad29f46b7a6992568de62033ee994c283b9495c4fdb"
oauth_provider_info['sc'][:redirect_uri] = "http://localhost:4000/redirect_from_oauth/sc"
oauth_provider_info['sc'][:site] = "http://localhost:3000"

oauth_provider_info['sc-heroku'][:clientid] = "138953f61a5ed49e5e6f3920da5f9ee83de453bdcf8fcf3987ec9bd07605b86a"
oauth_provider_info['sc-heroku'][:secret] = "a596e0426bc956d302e503c72753e66c37608e0b2b07736c532822db3cbb89ef"
oauth_provider_info['sc-heroku'][:redirect_uri] = "http://localhost:4000/redirect_from_oauth/sc"
oauth_provider_info['sc-heroku'][:site] = "http://eventually-ss.herokuapp.com:80/"

begin
  client = OAuth2::Client.new(oauth_provider_info[client_name][:clientid],\
                              oauth_provider_info[client_name][:secret], \
                              site: oauth_provider_info[client_name][:site])
rescue Exception => e
# do nothing
end


puts client.auth_code.authorize_url(redirect_uri: oauth_provider_info[client_name][:redirect_uri])

access = client.auth_code.get_token('e024f3604341b056fccd448765f7eaabbf364a3453fce865ad75985f0fec9710', redirect_uri: oauth_provider_info[client_name][:redirect_uri])
puts access.token


# sc 8e9e5fee1c72727cb294605ee9222f3d73a6317cfb63956425d4c1c380024e5f
# admin-heroku b7a5fbb9f890f1b9783ee74a93e2c640f910857d1cc0c6faf13b8eb361738cb7
# sc-heroku f071ef371948d4bc9f0b726d31f30e1800d3c3b44e45d572d2929932044ae393
