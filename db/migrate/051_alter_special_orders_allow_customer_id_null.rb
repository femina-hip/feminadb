class AlterSpecialOrdersAllowCustomerIdNull < ActiveRecord::Migration
  # Corrects the typo in CreateSpecialOrders
  def self.up
    change_column :special_orders, :customer_id, :integer, :default => nil
  end

  def self.down
    change_column :special_orders, :customer_id, :integer, :default => 0
  end
end
