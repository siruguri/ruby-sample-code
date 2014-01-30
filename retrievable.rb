require 'open-uri'
require 'openssl'
require 'json'

module Retrievable
  def self.readability_fetch(inp)

    params={token: "95bd44148fbd60663893a81de30ae4d7cd35ead8", url: inp}
    endpoint_uri = URI.parse 'https://www.readability.com/api/content/v1/parser'
    endpoint_uri.query=URI.encode_www_form params

    output = open(endpoint_uri, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE})
    obj = JSON.parse output.readlines.join("")

    [obj["excerpt"], obj["content"]]
  end
end
