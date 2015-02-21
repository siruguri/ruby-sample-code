require 'json'
require 'httparty'

class NetHttpFetch
  def initialize(uri='')
    @uri_string = uri
    @post_data = {}
  end
  
  def post_url
    @post_data.merge!({headers: {'Content-Type' => 'application/json'}})

    @resp=HTTParty.post(@uri_string, @post_data)
    {body: @resp.body}.merge(code_synonyms)
  end

  def post_data=(data_hash)
    @post_data.merge!({body: data_hash.to_json})
  end
    
  def get_url
    @resp = HTTParty.get @uri_string
    {body: @resp.body}.merge(code_synonyms)
  end

  private

  def code_synonyms
    {status_code: @resp.code, status: @resp.code, code: @resp.code}
  end
end
