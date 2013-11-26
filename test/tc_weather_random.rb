require_relative "../lib/weather_random"
require "test/unit"
 
class TestWeatherRandom < Test::Unit::TestCase

  def setup
    @key='15dd68101a1883ce'
    @url='http://api.wunderground.com/api/#key/conditions/q/CA/San_Francisco.json'
    @api=WeatherRandom::WeatherApi.new(@url, @key)
  end

  def test_make_api_object
    assert_equal("http://api.wunderground.com/api/#{@key}/conditions/q/CA/San_Francisco.json", @api.url)
    assert_equal(@key, @api.key)
  end

  def test_bad_api_create
    assert_raise (WeatherRandom::ImproperApiURL) { WeatherRandom::WeatherApi.new('http://api.wunderground.com/api/#/key/conditions/q/CA/San_Francisco.json', @key) }
  end

  def test_retrieve
    json_resp = @api.get_data
    assert_not_nil json_resp
    assert_not_nil json_resp['response']
    assert_equal('0.1',  json_resp['response']['version'])
  end
 
end
