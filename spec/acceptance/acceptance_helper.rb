require File.dirname(__FILE__) + "/../spec_helper"
require "steak"
require 'capybara/rails'
require 'capybara/envjs'

RSpec.configure do |config|
  config.include Capybara
  Capybara.javascript_driver = :envjs
end

# Put your acceptance spec helpers inside /spec/acceptance/support
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
