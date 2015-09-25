require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'sprockets/railtie'

# Auto-require default libraries and those for the current Rails environment.
Bundler.require :default, Rails.env

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Feminadb
  class Application < Rails::Application
    config.assets.enabled = true
    config.assets.version = '1.0'

    config.active_record.observers = :customer_note_observer

    config.encoding = 'utf-8'
    config.time_zone = 'UTC'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters << :password
    config.autoload_paths << Rails.root.join('lib')
  end
end
