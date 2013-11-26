require 'rest_client'

resp = RestClient.get('http://sameer_as:openstreetmapmrsmani@api.openstreetmap.org/api/0.6/user/details')
puts resp.inspect
