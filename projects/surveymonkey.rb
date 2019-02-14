require 'pry'
require_relative 'surveymonkey/lib/surveymonkey'

client = SurveyMonkeyApi::Client.new

# ELL API
client.token = 'UNEvOFpSMgTjIsyO8bPLEiuujmRF-I5W6KNU2dwhLokmEapxiemkFLdagdDVOKJt50UwD.JiTm.Yw7k2XLCXe5DDplqLicPso3jwTjJjUESmxhBPvKXdyI5NJFvl.mo2'

# My API
#client.token = 'hBD-ASxyjkbtY-o5lr6R6olwGwOw.1vJ8pmrSh0OaEE95gpQf15lwXQxuH735DCCDZ8JGudsu5BzcVVaeohD2nYmMx7.8gst5zXzu33kXfEgdrm2NWQnIpIqyzMEcyCc'

surveys = client.surveys
survey_id = surveys['data'][1]['id']
puts surveys['data'][1]['title']
puts client.pages(survey_id)
puts client.questions(survey_id).map { |q| q.to_json }.compact
exit

survey_pages = client.pages survey_id
puts client.page_ids survey_id

survey_pages.each do |page|
  page.questions.each do |question|
    puts question.details
  end
end
exit
responses = client.responses_with_details(survey_id)
puts responses

responses['data'].each do |response|
  response_id = response['id']
  response = client.response_with_details survey_id, response_id
  puts response['pages']
end

survey = client.survey_with_details(survey_id)
collectors = client.collectors survey_id
collector_id = collectors['data'].find { |i| i['name'] =~ /Shared link/ }['id']
