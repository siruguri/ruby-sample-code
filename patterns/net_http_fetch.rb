require 'json'
require 'httparty'

class NetHttpFetch
  def initialize(uri: '')
    @uri_string = uri
    @post_data = {}
    @opts = {}
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
  
  def post_url(uri = nil)
    @resp=do_protected_call(:post, uri)
    {body: @resp.body}.merge(code_synonyms)
  end
  alias :post :post_url

  def query_parameters(h)
    @opts[:query] = h
    self
  end
  
  def post_data=(data_hash)
    @post_data.merge!({body: data_hash})
  end
    
  def get_url(uri = nil)
    @resp = do_protected_call(:get, uri)
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

  def do_protected_call(method, uri = nil)
    # Run the HTTP requests within an exception rescue
    call_done = false
    ret = nil

    if @post_data.has_key? :body
      @opts[:body] = @post_data[:body].to_json
    end
    if @post_data.has_key? :headers
      @opts[:headers] = @post_data[:headers]
    end
    if @post_data.has_key? :basic_auth
      @opts[:basic_auth] = @post_data[:basic_auth]
    end

    _u = uri || @uri_string
    while(!call_done)
      begin
        case method
        when :get
          ret=HTTParty.get _u, @opts
        when :post
          ret=HTTParty.post _u, @opts
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

puts NetHttpFetch.new.get('https://twitter.com/search?q=%23npojobs&src=typd')
