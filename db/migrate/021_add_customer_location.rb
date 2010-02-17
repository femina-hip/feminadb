class AddCustomerLocation < ActiveRecord::Migration
  def self.up
    add_column :customers, :location, :string
    add_column :customers, :address, :string
    add_column :customers, :email, :string
    add_column :customer_versions, :location, :string
    add_column :customer_versions, :address, :string
    add_column :customer_versions, :email, :string
  end

  def self.down
    remove_column :customers, :location
    remove_column :customers, :address
    remove_column :customers, :email
    remove_column :customer_versions, :location
    remove_column :customer_versions, :address
    remove_column :customer_versions, :email
  end
end
