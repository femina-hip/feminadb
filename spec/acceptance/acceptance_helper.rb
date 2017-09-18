require File.dirname(__FILE__) + "/../rails_helper"
require 'capybara/rails'
require 'capybara/poltergeist'

RSpec.configure do |config|
  config.include Capybara::DSL
  Capybara.javascript_driver = :poltergeist
end

# Put your acceptance spec helpers inside /spec/acceptance/support
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
