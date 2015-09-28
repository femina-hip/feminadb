require 'rubygems'

ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require 'rspec/rails'
require 'database_cleaner'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec

  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
