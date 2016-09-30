Bundler.require :default, :development

Capybara.run_server = false
Capybara.default_driver = :webkit
Capybara.app_host = 'http://www.google.com'

Capybara::Webkit.configure do |config|
  config.allow_unknown_urls
end

require 'capybara/dsl'

class Runner
  include Capybara::DSL
  def testme
    visit 'http://www.spanishclassonline.com/vocabulary/occupationsProfessions.htm'
    elt = find :xpath, '/html/body/div[3]/center/table/tbody/tr/td/p/table/tbody/tr/td/table/tbody'
    puts elt.text
  end
end


Runner.new.testme
