class MakeCustomerTypeParanoidVersioned < ActiveRecord::Migration
  def self.up
    add_column :customer_types, :updated_at, :datetime, :default => nil
    add_column :customer_types, :updated_by, :integer, :default => nil
    add_column :customer_types, :version, :integer, :default => nil
    CustomerType.create_versioned_table
  end

  def self.down
    CustomerType.drop_versioned_table
    remove_column :customer_types, :version
    remove_column :customer_types, :updated_by
    remove_column :customer_types, :updated_at
  end
end
