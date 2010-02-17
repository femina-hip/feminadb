class AddCustomerRoute < ActiveRecord::Migration
  def self.up
    add_column :customers, :route, :string, :default => '', :null => false
    add_column :customer_versions, :route, :string, :default => '', :null => false
  end

  def self.down
    remove_column :customers, :route
    remove_column :customer_versions, :route
  end
end
