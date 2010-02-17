class AddSpecialOrderRequestedBy < ActiveRecord::Migration
  def self.up
    add_column :special_orders, :requested_by, :integer, :null => false, :default => 0
    add_column :special_order_versions, :requested_by, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :special_order_versions, :requested_by
    remove_column :special_orders, :requested_by
  end
end
