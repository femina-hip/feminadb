class CreateCustomers < ActiveRecord::Migration
  def self.up
    create_table :customers do |t|
      t.column :name, :string
      t.column :customer_type_id, :int
      t.column :region_id, :int
      t.column :district, :string
      t.column :contact_details, :string
      t.column :contact_details, :string
      t.column :updated_at, :datetime
      t.column :updated_by, :int
      t.column :version, :int
    end
    Customer.create_versioned_table
  end

  def self.down
    Customer.drop_versioned_table
    drop_table :customers
  end
end
