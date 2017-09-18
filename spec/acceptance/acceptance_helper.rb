require File.dirname(__FILE__) + "/../rails_helper"
require 'capybara/rails'
require 'selenium/webdriver'

RSpec.configure do |config|
  config.include Capybara::DSL

  Capybara.register_driver(:chrome) do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  end

  Capybara.register_driver(:headless_chrome) do |app|
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: { args: %w(headless disable-gpu) }
    )

    Capybara::Selenium::Driver.new(app,
      browser: :chrome,
      desired_capabilities: capabilities
    )
  end

  Capybara.javascript_driver = :chrome # will show testing in a new Chrome window
  #Capybara.javascript_driver = :headless_chrome # will not show testing
end

# Put your acceptance spec helpers inside /spec/acceptance/support
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
