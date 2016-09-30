require 'json'
require 'httparty'

class NetHttpFetch
  def initialize(uri: '')
    @uri_string = uri
    @post_data = {}
  end

  def basic_auth(auth_hash = nil)
    if auth_hash.nil?
      @post_data[:basic_auth]
    else
      @post_data[:basic_auth] = auth_hash
    end
  end

  def add_headers(hash)
    @post_data.merge!({headers: hash})
  end
  
  def post_url
    @resp=do_protected_call(:post)
    {body: @resp.body}.merge(code_synonyms)
  end
  alias :post :post_url

  def post_data=(data_hash)
    @post_data.merge!({body: data_hash})
  end
    
  def get_url
    @resp = do_protected_call(:get)
    {body: @resp.body}.merge(code_synonyms)
  end
  alias :get :get_url

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

    opts = {}
    if @post_data.has_key? :body
      opts[:body] = @post_data[:body].to_json
    end
    if @post_data.has_key? :headers
      opts[:headers] = @post_data[:headers]
    end
    if @post_data.has_key? :basic_auth
      opts[:basic_auth] = @post_data[:basic_auth]
    end
    
    while(!call_done)
      begin
        case method
        when :get
          ret=HTTParty.get @uri_string, opts
        when :post
          ret=HTTParty.post @uri_string, opts
        end
      rescue Errno::ETIMEDOUT, SocketError => e
        # When this error occurs, let's back off and re-try
        $stderr.write "Timed out. Will retry in 5 seconds.\n"
        sleep 5
      else
        call_done = true
      end
    end

    ret
  end
      
end
