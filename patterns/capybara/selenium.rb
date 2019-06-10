require "selenium-webdriver"

class Runner
  attr_accessor :driver
  def initialize
    @driver = Selenium::WebDriver.for :firefox
  end

  def testme
    driver.navigate.to 'http://www.spanishclassonline.com/vocabulary/occupationsProfessions.htm'
    elt = driver.find_element :xpath, '/html/body/div[3]/center/table/tbody/tr/td/table/tbody/tr/td/table/tbody/tr[2]/td[1]'
    puts elt.text
  end

  def close
    driver.close
  end
end


r = Runner.new
r.testme
r.close
