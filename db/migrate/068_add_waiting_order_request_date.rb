class AddWaitingOrderRequestDate < ActiveRecord::Migration
  def self.up
    add_column :waiting_orders, :request_date, :date, :null => false
    add_column :waiting_order_versions, :request_date, :date, :null => false
    WaitingOrder.connection.update_sql "UPDATE waiting_orders SET request_date = updated_at"
    WaitingOrder.connection.update_sql "UPDATE waiting_order_versions SET request_date = updated_at"
  end

  def self.down
    remove_column :waiting_orders, :request_date
    remove_column :waiting_order_versions, :request_date
  end
end
