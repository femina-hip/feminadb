class AlterSpecialOrdersAddComplete < ActiveRecord::Migration
  def self.up
    add_column :special_orders, :completed_by, :integer
    add_column :special_orders, :completed_at, :datetime
    add_column :special_order_versions, :completed_by, :integer
    add_column :special_order_versions, :completed_at, :datetime
  end

  def self.down
    remove_column :special_orders, :completed_at
    remove_column :special_orders, :completed_by
    remove_column :special_order_versions, :completed_at
    remove_column :special_order_versions, :completed_by
  end
end
