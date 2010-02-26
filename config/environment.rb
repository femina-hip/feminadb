# Be sure to restart your web server when you modify this file.

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store
  config.action_controller.session = {
    :session_key => '_feminadb_session_id',
    :secret => '3a09327a05fe2e0eb6d532bcf2f44f16fe6f6ec835ef7676fb544ec59123775b'
  }

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  #config.active_record.observers = :special_order

  config.gem 'will_paginate', :version => '2.3.12'
  config.gem 'RedCloth', :version => '4.1.9', :lib => 'redcloth'
  config.gem 'vestal_versions', :version => '1.0.2'
  config.gem 'sunspot', :version => '0.10.8'
  config.gem 'sunspot_rails', :version => '0.11.5', :lib => 'sunspot/rails'
end

# This is a Rails bug #9773 and there is a patch
ActiveRecord::Base.observers = :special_order_observer, :customer_note_observer, :club_observer
ActiveRecord::Base.instantiate_observers
