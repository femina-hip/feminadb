require 'spec_helper'

ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require 'rspec/rails'

def disable_transactions_forever
  # ActiveRecord uses transactions. We don't, because:
  #
  # A) creating a Customer in a transaction will commit to Sunspot, leading to
  #    inconsistency; and
  # B) acceptance tests can use multiple simultaneous connections, leading to
  #    non-visibility
  ActiveRecord::ConnectionAdapters::Mysql2Adapter.class_eval do
    def begin_db_transaction; end
    def begin_isolated_db_transaction(isolation); end
    def commit_db_transaction; end
    def exec_rollback_db_transaction; end
  end
end

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.before(:all) { disable_transactions_forever }

  config.before(:each) do
    Sunspot.remove_all
    tables = %w(
      audits
      bulk_order_creators
      customer_notes
      customer_types
      customers
      delivery_methods
      districts
      issue_notes
      issues
      orders
      publications
      regions
      standing_orders
      tags
      users
    )
    Customer.connection.execute <<-EOT
      SET foreign_key_checks=0;
      #{tables.map{ |table| "DELETE FROM #{table}" }.join(";\n")};
      SET foreign_key_checks=1;
    EOT
    Customer.connection.raw_connection.abandon_results!
  end
end
