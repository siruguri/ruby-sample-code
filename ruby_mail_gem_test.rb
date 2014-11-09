require 'mail'
   
# === Sending via GMail
options= { :address              => "dstrategies.org",
  :port                 => 587,
  :domain               => 'dstrategies.org',
  :user_name            => 'sameer',
  :password             => 'zebra mimic burst',
  :authentication       => 'plain',
  :enable_starttls_auto => true  }

Mail.defaults do
  delivery_method :smtp, options
end

mail = Mail.new do
      to 'siruguri@gmail.com'
      from 'sameer@dstrategies.org'
      subject 'Test email'
      body ('Nothing really')
end

mail.deliver
