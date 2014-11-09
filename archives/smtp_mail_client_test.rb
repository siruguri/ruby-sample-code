require 'net/smtp'

module MailerModule
  class MyMailer
    @@sender_name = "Sameer's Monitoring Script"

    def initialize(msg_type)
      if msg_type=="info"
        @to_list = 'Sameer <ssiruguri@techsoupglobal.org>'
      else
        @to_list = 'Sameer Siruguri <ssiruguri@techsoupglobal.org>; William Coonan <wcoonan@techsoupglobal.org>; Ariel Gilbert-Knight <agknight@techsoupglobal.org>'
      end

      @@msg_header = <<END
From: #{@@sender_name} <ssiruguri@techsoupglobal.org>
To: #{@to_list}
MIME-Version: 1.0
Content-type: text/html
Subject: SMTP e-mail test
END
    end

    attr_accessor :message

    def email (options={})
      data = make_message(options)

      if /_test/.match __FILE__
        puts data
      end

      smtp = make_smtp_client()
      
      smtp.start('smtp.gmail.com', 'siruguri', 'utflpjefsnnkvybp', :login) do |smtp|
        smtp.send_message data, 'siruguri@gmail.com', 'ssiruguri@techsoupglobal.org'
      end
    end

    private
    def make_smtp_client
      smtp=Net::SMTP.new('smtp.gmail.com',587)
      smtp.enable_starttls
      smtp
    end

    def make_message (options)
      mesg_type = (options.key? :status) ? options[:status] : "no change"
      uri = (options.key? :uri) ? options[:uri] : "http://www.techsoup.org"
      add_mesg = (options.key? :message) ? options[:message] : ""

      mesg = @@msg_header
      mesg = mesg + "Sameer's script checked <a href=#{uri}>#{uri}</a> for changes, and found that <b>"

      mesg = mesg +
        (case mesg_type
        when "no change"
          "nothing changed"
        when "changed"
          "something changed"
        when "fetch fail"
          "the fetch failed"
        end) + "</b>."

      if mesg_type == "changed"
        mesg += "<h2>Additional Notes</h2>#{add_mesg}"
      end


      mesg
    end
  end

end

