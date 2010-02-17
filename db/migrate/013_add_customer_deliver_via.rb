class AddCustomerDeliverVia < ActiveRecord::Migration
  def self.up
    add_column :customers, :deliver_via, :string
    add_column :customer_versions, :deliver_via, :string
  end

  def self.down
    remove_column :customers, :deliver_via
    remove_column :customer_versions, :deliver_via
  end
end
