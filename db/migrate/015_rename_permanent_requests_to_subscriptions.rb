class RenamePermanentRequestsToSubscriptions < ActiveRecord::Migration
  def self.up
    rename_column :requests, :permanent_request_id, :subscription_id
    rename_column :request_versions, :permanent_request_id, :subscription_id
    rename_column :subscription_versions, :permanent_request_id, :subscription_id
    rename_table :permanent_requests, :subscriptions
  end

  def self.down
    rename_table :subscriptions, :permanent_requests
    rename_table :subscription_versions, :permanent_request_versions
    rename_column :subscription_versions, :subscription_id, :permanent_request_id
    rename_column :requests, :subscription_id, :permanent_request_id
    rename_column :request_versions, :subscription_id, :permanent_request_id
  end
end
