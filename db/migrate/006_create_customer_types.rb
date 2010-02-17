class CreateCustomerTypes < ActiveRecord::Migration
  def self.up
    create_table :customer_types do |t|
      t.column :name, :string
    end
    CustomerType.enumeration_model_updates_permitted = true
    CustomerType.create :name => 'Secondary School'
    CustomerType.create :name => 'NGO'
    CustomerType.create :name => 'Business'
    CustomerType.create :name => 'College'
    CustomerType.create :name => 'Government'
    CustomerType.create :name => 'Institution'
    CustomerType.create :name => 'Religious'
    CustomerType.create :name => 'Youth Group'
    CustomerType.create :name => 'Unknown'
  end

  def self.down
    drop_table :customer_types
  end
end
