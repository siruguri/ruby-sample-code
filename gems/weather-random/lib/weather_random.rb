require 'open-uri'
require 'json'

module WeatherRandom
  class ImproperApiURL < Exception
  end

  class WeatherApi
    def initialize(url, key)
      raise(ImproperApiURL) if !(/\#key/.match url)

      @uri=url
      @key=key


      @uri = @uri.gsub(/\#key/, @key)
    end
      
    attr_accessor :uri, :key

    def fetch_uri
      data = open @uri
      @json_data = JSON.parse (data.readlines.join "")
    end


    def set_data inp_str
      # Parse a JSON string
      @json_data = JSON.parse inp_str
    end

    def make_seed
      # Returns a string that can be used as the seed for Rand

      # Concatenate a pre-selected list of keys from the feed. This is specific to Wunderground - it needs to be configurable
      string = (['temp_f', 'pressure_mb', 'pressure_in', 'wind_degrees', 'wind_mph', 'wind_gust_mph'].map do |key|
        @json_data['current_observation'][key]
                end).join("")

      seed = (string.split("").map do |char|
        char.unpack('C')[0].to_s
              end).join ""

      seed.to_i
    end      
  end


end

