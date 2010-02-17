class CreateDeliveryMethods < ActiveRecord::Migration
  def self.up
    create_table :delivery_methods do |t|
      t.column :name, :string
      t.column :description, :string
    end

    DeliveryMethod.create :name => 'Dar es Salaam',
                          :description => 'Delivered within Dar es Salaam'
    DeliveryMethod.create :name => 'Up-Country',
                          :description => 'Delivered by EAM up-country'
    DeliveryMethod.create :name => 'Up-Country Corporate',
                          :description => 'Delivered by EAM up-country, recipient pays transport costs'

    add_column :customers, :delivery_method_id, :integer
    add_column :customer_versions, :delivery_method_id, :integer
  end

  def self.down
    remove_column :customers, :delivery_method_id
    remove_column :customer_versions, :delivery_method_id

    drop_table :delivery_methods
  end
end
