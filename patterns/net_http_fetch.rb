require 'json'
require 'httparty'

class NetHttpFetch
  def initialize(uri='')
    @uri_string = uri
    @post_data = {}
  end
  
  def post_url
    @post_data.merge!({headers: {'Content-Type' => 'application/json'}})

    @resp=do_protected_call(:post)
    {body: @resp.body}.merge(code_synonyms)
  end

  def post_data=(data_hash)
    @post_data.merge!({body: data_hash.to_json})
  end
    
  def get_url
    @resp = do_protected_call(:get)
    {body: @resp.body}.merge(code_synonyms)
  end

  def uri=(uri)
    @uri_string = uri
  end
  alias :url= :uri=
  
  private

  def code_synonyms
    {status_code: @resp.code, status: @resp.code, code: @resp.code}
  end

  def do_protected_call(method)
    # Run the HTTP requests within an exception rescue
    call_done = false
    ret = nil
    while(!call_done)
      begin
        case method
        when :get      
          ret=HTTParty.get @uri_string
        when :post
          ret=HTTParty.post(@uri_string, @post_data)
        end
      rescue Errno::ETIMEDOUT, SocketError => e
        # When this error occurs, let's back off and re-try
        sleep 5
      else
        call_done = true
      end
    end

    ret
  end
      
end
