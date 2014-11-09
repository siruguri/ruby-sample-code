require 'open-uri'
require 'json'
require 'httparty'

uri_string='https://api.finder.healthcare.gov/v3.0/getIFPPlanQuotes'
uri_string='https://api.finder.healthcare.gov/v3.0/getIFPPlanBenefits'

data=File.open('input.txt', 'r').readlines.join('')
resp=HTTParty.post(uri_string, headers: {'Content-Type' => 'application/xml'},
                   body: data )
puts resp.body
puts resp.code
