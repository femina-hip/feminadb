class IndexWaitingOrders < ActiveRecord::Migration
  def self.up
    add_index :waiting_orders, :publication_id
    add_index :waiting_orders, :customer_id
  end

  def self.down
    remove_index :waiting_orders, :publication_id
    remove_index :waiting_orders, :customer_id
  end
end
