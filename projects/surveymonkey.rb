require 'pry'
require_relative 'surveymonkey/lib/surveymonkey'

# ELL API
SurveyMonkeyApi::Client.token = 'aCtgpdlKDOVZsJwDahSL9QeR64q3tOZODG3kn4J4iUzXzunCZdVUgf9u-5Z-VY79wPcFD3nathJg64CkpJSdmt3WCmCKIpjENiiynehoF1kYRaxlffmo-AGb7EXq2MtBh'

client = SurveyMonkeyApi::Client.new
survey_id = '166340575'
responses = client.responses_with_details(survey_id, per_page: 50)
puts "Pass: #{responses['data'].size > 50}"
exit
# My API
#client.token = 'hBD-ASxyjkbtY-o5lr6R6olwGwOw.1vJ8pmrSh0OaEE95gpQf15lwXQxuH735DCCDZ8JGudsu5BzcVVaeohD2nYmMx7.8gst5zXzu33kXfEgdrm2NWQnIpIqyzMEcyCc'

client.webhook_response_complete ["166016943", "165705321", "165704898", "165856653", "166340575", "165705936", "165473072", "166340311"], 'https://ell-pilot.herokuapp.com/surveymonkey_callback'
client = SurveyMonkeyApi::Webhook.new
puts client.fetch_all.webhooks
#puts client.delete_all
puts client.api_limit_day
exit
surveys = client.surveys

survey_id = surveys['data'][1]['id']
puts surveys['data'][1]['title']

puts client.questions(survey_id).map { |q| q.to_json }.compact
puts client.api_limit_day
exit

survey_pages = client.pages survey_id
puts client.page_ids survey_id

survey_pages.each do |page|
  page.questions.each do |question|
    puts question.details
  end
end
exit

responses['data'].each do |response|
  response_id = response['id']
  response = client.response_with_details survey_id, response_id
  puts response['pages']
end

survey = client.survey_with_details(survey_id)
collectors = client.collectors survey_id
collector_id = collectors['data'].find { |i| i['name'] =~ /Shared link/ }['id']
