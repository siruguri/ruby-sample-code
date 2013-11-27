require 'rubygems'
gem 'minitest'

require_relative "../lib/weather_random"
require "minitest/autorun"
 
describe WeatherRandom do

  before do
    @key='15dd68101a1883ce'
    @url='http://api.wunderground.com/api/#key/conditions/q/CA/San_Francisco.json'
    @api=WeatherRandom::WeatherApi.new(@url, @key)
  end

  describe "when an object is created" do
    it "must have a URL" do
      @api.uri.must_equal "http://api.wunderground.com/api/#{@key}/conditions/q/CA/San_Francisco.json"
    end

    it "must have a key" do
      @api.key.must_equal @key
    end

    it "wont let the URL not have a key placeholder" do
      proc { WeatherRandom::WeatherApi.new('http://api.wunderground.com/api/#/key/conditions/q/CA/San_Francisco.json', @key) }.must_raise WeatherRandom::ImproperApiURL
    end

  end

  describe "for a valid object" do
    before do
      @json_resp = @api.set_data((File.open 'test/data_sf.json').readlines.join "")
    end

    it "can retrieve data" do
      @json_resp.wont_equal nil
      @json_resp['response'].wont_equal nil
      @json_resp['response']['version'].must_equal '0.1'


      ['temp_f', 'pressure_mb', 'pressure_in', 'wind_degrees', 'wind_mph', 'wind_gust_mph'].each do |key|
        @json_resp['current_observation'][key].wont_equal nil
      end
    end

    it "returns a seed" do 
      expected_seed = ('54.7102530.27230.00'.split("").map do |char|
                         char.unpack('C')[0].to_s
                       end).join ""
      @api.make_seed.must_equal expected_seed.to_i
    end
  end
end
