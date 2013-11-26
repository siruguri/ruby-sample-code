require 'open-uri'
require 'json'

module WeatherRandom
  class ImproperApiURL < Exception
  end

  class WeatherApi
    def initialize(url, key)
      raise(ImproperApiURL) if !(/\#key/.match url)

      @url=url
      @key=key


      @url = @url.gsub(/\#key/, @key)
    end
      
    attr_accessor :url, :key

    def get_data
      data = open @url
      @json_data = JSON.parse (data.readlines.join "")
    end
  end


end

