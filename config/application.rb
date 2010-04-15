require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Auto-require default libraries and those for the current Rails environment.
Bundler.require :default, Rails.env

module Feminadb
  class Application < Rails::Application
    config.active_record.observers = :special_order_observer, :customer_note_observer, :club_observer

    config.time_zone = 'Nairobi'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters << :password

    config.session_store(
      :cookie_store,
      :key    => '_feminadb_session',
      :secret => '92ba21b35fb78673b7207957cbf83236e77388b2a460bbce935e3ea86baa0fdaffcbc8ef4d92f8c7da805f202e6a717b0e32dce119f50a6a050265b8cd94e9cf'
    )

    config.secret_token = 'd307f8ef2f161c536015ba537fae2f06a8342e322d5ab0bc93dfe80ddf23703bd39b17330d0d23ab7f700bef7388c4fc2ca4a373a4b86cec5a7fd86281d45a02'
  end
end
