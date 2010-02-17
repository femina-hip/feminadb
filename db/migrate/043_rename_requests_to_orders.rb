class RenameRequestsToOrders < ActiveRecord::Migration
  def self.up
    rename_table :request_statuses, :order_statuses

    rename_column :requests, :request_date, :order_date
    rename_column :requests, :request_status_id, :order_status_id
    rename_column :request_versions, :request_id, :order_id
    rename_column :request_versions, :request_date, :order_date
    rename_column :request_versions, :request_status_id, :order_status_id

    rename_table :requests, :orders
    rename_table :request_versions, :order_versions
  end

  def self.down
    rename_table :order_statuses, :order_statuses

    rename_column :orders, :order_date, :request_date
    rename_column :orders, :order_status_id, :request_status_id
    rename_column :order_versions, :order_id, :request_id
    rename_column :order_versions, :order_date, :request_date
    rename_column :order_versions, :order_status_id, :request_status_id

    rename_table :orders, :requests
    rename_table :order_versions, :request_versions
  end
end
