require "selenium-webdriver"

class Runner
  attr_accessor :driver
  attr_reader :url
  def initialize(url)
    @url = url
    @driver = Selenium::WebDriver.for :firefox
  end

  def testme
    driver.navigate.to url
    puts 'press enter to continue'
    input = $stdin.readline
  end

  def close
    driver.close
  end
end


r = Runner.new ARGV[0]
r.testme
r.close
