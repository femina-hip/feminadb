require_relative 'boot'

require 'rails/all'
require 'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Feminadb
  class Application < Rails::Application
    config.assets.enabled = true
    config.assets.version = '1.0'

    config.encoding = 'utf-8'
    config.time_zone = 'UTC'
  end
end
