require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Auto-require default libraries and those for the current Rails environment.
Bundler.require :default, Rails.env

module Feminadb
  class Application < Rails::Application
    config.active_record.observers = :special_order_observer, :customer_note_observer

    config.time_zone = 'Nairobi'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters << :password
  end
end
