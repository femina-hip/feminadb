class AddCustomerDetailsToRequest < ActiveRecord::Migration
  def self.up
    add_column :requests, :region_id, :integer
    add_column :requests, :district, :string
    add_column :requests, :customer_name, :string
    add_column :requests, :deliver_via, :string
    add_column :requests, :delivery_method_id, :integer
    add_column :requests, :contact_name, :string
    add_column :requests, :contact_details, :string
    add_column :request_versions, :region_id, :integer
    add_column :request_versions, :district, :string
    add_column :request_versions, :customer_name, :string
    add_column :request_versions, :deliver_via, :string
    add_column :request_versions, :delivery_method_id, :integer
    add_column :request_versions, :contact_name, :string
    add_column :request_versions, :contact_details, :string
  end

  def self.down
    remove_column :requests, :region_id
    remove_column :requests, :district
    remove_column :requests, :customer_name
    remove_column :requests, :deliver_via
    remove_column :requests, :delivery_method_id
    remove_column :requests, :contact_name
    remove_column :requests, :contact_details
    remove_column :request_versions, :region_id
    remove_column :request_versions, :district
    remove_column :request_versions, :customer_name
    remove_column :request_versions, :deliver_via
    remove_column :request_versions, :delivery_method_id
    remove_column :request_versions, :contact_name
    remove_column :request_versions, :contact_details
  end
end
