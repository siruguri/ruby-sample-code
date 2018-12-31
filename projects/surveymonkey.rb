require 'surveymonkey'

ENV['SURVEY_MONKEY_TOKEN'] = 'hBD-ASxyjkbtY-o5lr6R6olwGwOw.1vJ8pmrSh0OaEE95gpQf15lwXQxuH735DCCDZ8JGudsu5BzcVVaeohD2nYmMx7.8gst5zXzu33kXfEgdrm2NWQnIpIqyzMEcyCc'
survey_id = 'Z2r2MNicKDG5rqqZsowNdFdcnVJu4gtzZPc9PzIYTKa600kj7_2BQxO0wqYaLr0oSz'
client = SurveyMonkeyApi::Client.new

surveys = client.surveys
survey_id = surveys['data'][0]['id']

survey = client.survey_with_details(survey_id)
collectors = client.collectors survey_id
collector_id = collectors['data'].find { |i| i['name'] =~ /Shared link/ }['id']
puts client.collector(collector_id)['url']
exit

responses = client.responses(survey_id)
responses['data'].each do |response|
  response_id = response['id']
  response = client.response_with_details survey_id, response_id
  puts response['pages']
end

