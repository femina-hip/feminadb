class AddCustomerContactName < ActiveRecord::Migration
  def self.up
    add_column :customers, :contact_name, :string
    add_column :customer_versions, :contact_name, :string
  end

  def self.down
    remove_column :customers, :contact_name
    remove_column :customer_versions, :contact_name
  end
end
