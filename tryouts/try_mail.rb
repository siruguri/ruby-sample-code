require './mailer_client.rb'

client = MailerModule::MailerClient.new(from: 'siruguri@gmail.com', to: 'ssiruguri@techsoupglobal.org; cheapkettle@gmail.com; sameers.public@gmail.com')

if !client.nil?
  client.subject = "subjected!"
  client.message = "messaged!"
  
  puts client.email
end
  
  
