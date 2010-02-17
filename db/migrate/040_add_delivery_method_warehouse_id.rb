class AddDeliveryMethodWarehouseId < ActiveRecord::Migration
  def self.up
    add_column :delivery_methods, :warehouse_id, :integer
  end

  def self.down
    remove_column :delivery_methods, :warehouse_id
  end
end
